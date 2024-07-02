#include "Internal.hpp"

#include <algorithm>
#include <iostream>
#include <fstream>

#include <QtDebug>
#include <QFileDialog>

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>

#include <cvmatandqimage.h>

#include <base64.hpp>

#include "Base.hpp"
#include "Core/FileSystem.hpp"
#include "Core/Helper.hpp"

Financy::User* selectedUser;

namespace Financy
{
    void Internal::setSelectedUser(User* inUser)
    {
        selectedUser = inUser;
    }

    User* Internal::getSelectedUser()
    {
        return selectedUser;
    }

    Internal::Internal(QObject* parent)
        : QObject(parent),
        m_colors(new Colors(parent)),
        m_showcaseColors(new Colors(parent)),
        m_selectedUser(nullptr),
        m_selectedAccount(nullptr)
    {
        createFiles();

        loadSettings();
        loadUsers();
        loadAccounts();
        setUsersAccounts();

        normalizePurchases();
    }

    Internal::~Internal()
    {
        for (QObject* user : m_users)
        {
            delete user;
        }

        delete m_colors;
    }

    QString Internal::openFileDialog(
        const QString& inTitle,
        const QString& inExtensions
    )
    {
        QString fileExtensions = "Files";
        fileExtensions.push_back(" (");
        for (std::string& fileExtension : Helper::splitString(inExtensions.toStdString(), ";"))
        {
            fileExtensions.push_back(QString::fromLatin1("*." + fileExtension + " "));
        }
        fileExtensions.push_back(")");

        return QFileDialog::getOpenFileUrl(
            nullptr,
            inTitle,
            QUrl::fromLocalFile("/"),
            fileExtensions
        ).url();
    }

    QList<QColor> Internal::getUserColorsFromImage(const QString& inImage)
    {
        if (inImage.isEmpty() || inImage.toStdString().find("qrc://") != std::string::npos)
        {
            return { "#000000", "#FFFFFF" };
        }

        #ifdef OS_WINDOWS
            std::vector<std::string> splittedUrl = Helper::splitString(
                inImage.toStdString(),
                "file:///"
            );
        #else
            std::vector<std::string> splittedUrl = Helper::splitString(
                inImage.toStdString(),
                "file://"
            );
        #endif

        std::string filePath = splittedUrl[splittedUrl.size() - 1];
        std::vector<std::string> splittedFilepath = Helper::splitString(
            filePath,
            "."
        );

        std::string fileExtension = splittedFilepath[splittedFilepath.size() - 1];

        std::vector<char> raw = FileSystem::readFile(filePath);
        std::string sRaw(raw.begin(), raw.end());

        QImage image;
        image.loadFromData(
            QByteArray::fromBase64(
                base64::to_base64(sRaw).c_str()
            )
        );

        cv::Scalar prominentColor = cv::mean(
            QtOcv::image2Mat(image)
        );

        QColor primaryColor = QColor(
            prominentColor[0], // R
            prominentColor[1], // G
            prominentColor[2]  // B
        );
        QColor secondaryColor = QColor(
            255 - primaryColor.red(),
            255 - primaryColor.green(),
            255 - primaryColor.blue()
        );

        QList<QColor> result;
        result.push_back(primaryColor);
        result.push_back(secondaryColor);

        return result;
    }

    User* Internal::getUser(std::uint32_t inId)
    {
        for (int i = 0, j = m_users.size() - 1; i <= j; i++, j--)
        {
            if (m_users[i]->getId() == inId)
            {
                return m_users[i];
            }

            if (i == j)
            {
                continue;
            }

            if (m_users[j]->getId() == inId)
            {
                return m_users[j];
            }
        }

        return nullptr;
    }

    QList<User*> Internal::getUsers(const QList<int>& inIds)
    {
        QList<User*> result {};

        for (int i = 0, j = m_users.size() - 1; i <= j; i++, j--)
        {
            std::uint32_t leftUserId  = m_users[i]->getId();
            std::uint32_t rightUserId = m_users[j]->getId();

            if (
                std::find_if(
                    inIds.begin(),
                    inIds.end(),
                    [leftUserId](int _) { return _ == leftUserId; }
                ) != inIds.end()
            )
            {
                result.push_back(m_users[i]);
            }

            if (i == j)
            {
                continue;
            }

            if (
                std::find_if(
                    inIds.begin(),
                    inIds.end(),
                    [rightUserId](int _) { return _ == rightUserId; }
                ) != inIds.end()
            )
            {
                result.push_back(m_users[j]);
            }
        }

        std::sort(
            result.begin(),
            result.end(),
            [](User* a, User* b) { return a->getId() < b->getId(); }
        );

        return result;
    }

    User* Internal::createUser(
        const QString& inFirstName,
        const QString& inLastName,
        const QUrl& inPicture,
        const QColor& inPrimaryColor,
        const QColor& inSecondaryColor
    )
    {
        if (inFirstName.isEmpty())
        {
            return nullptr;
        }

        std::ifstream file(USER_FILE_NAME);
        nlohmann::ordered_json users = FileSystem::doesFileExist(USER_FILE_NAME) ? 
            nlohmann::ordered_json::parse(file):
            nlohmann::ordered_json::array();

        std::uint32_t id = 0;

        if (users.size() > 0)
        {
            id = (std::uint32_t) users[users.size() - 1].at("id");
            id++;
        }

        User* user = new User();
        user->setId(            id);
        user->setFirstName(     inFirstName);
        user->setLastName(      inLastName);
        user->setPicture(       inPicture);
        user->setPrimaryColor(  inPrimaryColor);
        user->setSecondaryColor(inSecondaryColor);

        m_users.push_back(user);

        onUsersUpdate();

        // Write
        users.push_back(user->toJSON());

        std::ofstream stream(USER_FILE_NAME);
        stream << std::setw(4) << users << std::endl;

        return user;
    }

    void Internal::editUser(
        std::uint32_t inId,
        const QString& inFirstName,
        const QString& inLastName,
        const QUrl& inPicture,
        const QColor& inPrimaryColor,
        const QColor& inSecondaryColor
    )
    {
        if (!FileSystem::doesFileExist(USER_FILE_NAME))
        {
            return;
        }

        User* user = getUser(inId);

        if (!user)
        {
            return;
        }

        nlohmann::ordered_json users = nlohmann::ordered_json::parse(std::ifstream(USER_FILE_NAME));

        if (!users.is_array())
        {
            return;
        }

        user->edit(
            inFirstName,
            inLastName,
            inPicture,
            inPrimaryColor,
            inSecondaryColor
        );

        nlohmann::ordered_json updatedUsers = nlohmann::ordered_json::array();

        for (auto& [key, data] : users.items())
        {
            if (data.find("id") == data.end() || !data.at("id").is_number_unsigned())
            {
                continue;
            }

            if ((int) data.at("id") != inId)
            {
                updatedUsers.push_back(data);

                continue;
            }

            updatedUsers.push_back(m_selectedUser->toJSON());
        }

        // Write
        std::ofstream stream(USER_FILE_NAME);
        stream << std::setw(4) << updatedUsers << std::endl;

        emit onSelectUserUpdate();
        emit onUsersUpdate();
    }

    void Internal::deleteUser(std::uint32_t inId)
    {
        User* user = getUser(inId);

        if (user == nullptr)
        {
            return;
        }
        
        login(inId);

        for (Account* account : user->getAccounts())
        {
            deleteAccount(account->getId());
        }

        user->remove();

        m_users.removeAt(
            std::find_if(
                m_users.begin(),
                m_users.end(),
                [user](User* _) { return _->getId() == user->getId(); }
            ) - m_users.begin()
        );

        logout();

        emit onUsersUpdate();

        delete user;
    }

    void Internal::login(std::uint32_t inId)
    {
        User* user = getUser(inId);

        if (user == nullptr)
        {
            return;
        }

        if (m_selectedUser != nullptr && user->getId() == m_selectedUser->getId())
        {
            return;
        }

        if (m_selectedUser != nullptr)
        {
            m_selectedUser->logout();
            m_selectedUser = nullptr;
        }

        setSelectedUser(user);

        m_selectedUser = user;
        m_selectedUser->login();

        emit onSelectUserUpdate();
    }

    void Internal::logout()
    {
        if (m_selectedUser == nullptr)
        {
            return;
        }

        m_selectedUser->logout();
        m_selectedUser = nullptr;

        setSelectedUser(m_selectedUser);

        emit onSelectUserUpdate();
    }

    Account* Internal::getAccount(std::uint32_t inId)
    {
        for (Account* account : m_accounts)
        {
            if (account->getId() != inId)
            {
                continue;
            }

            return account;
        }

        return nullptr;
    }

    QList<Account*> Internal::getAccounts(Account::Type inType)
    {
        QList<Account*> result {};

        for (Account* account : m_accounts)
        {
            if (account->getType() != inType)
            {
                continue;
            }

            result.push_back(account);
        }

        std::sort(
            result.begin(),
            result.end(),
            [](Account* a, Account* b) { return a->getId() < b->getId(); }
        );

        return result;
    }

    QList<Account*> Internal::getAccounts(const QList<int>& inIds)
    {
        QList<Account*> result {};

        for (int i = 0, j = m_accounts.size() - 1; i <= j; i++, j--)
        {
            std::uint32_t leftUserId  = m_accounts[i]->getId();
            std::uint32_t rightUserId = m_accounts[j]->getId();

            if (
                std::find_if(
                    inIds.begin(),
                    inIds.end(),
                    [leftUserId](int _) { return _ == leftUserId; }
                ) != inIds.end()
            )
            {
                result.push_back(m_accounts[i]);
            }

            if (i == j)
            {
                continue;
            }

            if (
                std::find_if(
                    inIds.begin(),
                    inIds.end(),
                    [rightUserId](int _) { return _ == rightUserId; }
                ) != inIds.end()
            )
            {
                result.push_back(m_accounts[j]);
            }
        }

        std::sort(
            result.begin(),
            result.end(),
            [](Account* a, Account* b) { return a->getId() < b->getId(); }
        );

        return result;
    }

    void Internal::createAccount(
        const QString& inName,
        const QString& inClosingDay,
        const QString& inLimit,
        const QString& inType,
        const QColor& inPrimaryColor,
        const QColor& inSecondaryColor
    )
    {
        if (m_selectedUser == nullptr)
        {
            return;
        }

        std::ifstream file(ACCOUNT_FILE_NAME);
        nlohmann::ordered_json accounts = FileSystem::doesFileExist(ACCOUNT_FILE_NAME) ? 
            nlohmann::ordered_json::parse(file):
            nlohmann::ordered_json::array();

        if (!accounts.is_array())
        {
            return;
        }

        std::uint32_t id = 0;

        if (accounts.size() > 0)
        {
            id = (std::uint32_t) accounts[accounts.size() - 1].at("id");
            id++;
        }

        Account* account = new Account();
        account->setId(            id);
        account->setUserId(        m_selectedUser->getId());
        account->setName(          inName);
        account->setClosingDay(    inClosingDay.toUInt());
        account->setLimit(         inLimit.toUInt());
        account->setPrimaryColor(  inPrimaryColor);
        account->setSecondaryColor(inSecondaryColor);
        account->setType(          Account::getTypeValue(inType));

        m_accounts.push_back(account);

        emit onAccountsUpdate();

        m_selectedUser->addAccount(account);

        writeAccounts();
    }

    void Internal::editAccount(
        std::uint32_t inId,
        const QString& inName,
        const QString& inClosingDay,
        const QString& inLimit,
        const QString& inType,
        const QColor& inPrimaryColor,
        const QColor& inSecondaryColor
    )
    {
        if (m_selectedUser == nullptr)
        {
            return;
        }

        if (!FileSystem::doesFileExist(ACCOUNT_FILE_NAME))
        {
            return;
        }

        nlohmann::ordered_json accounts = nlohmann::ordered_json::parse(std::ifstream(ACCOUNT_FILE_NAME));

        if (!accounts.is_array())
        {
            return;
        }

        nlohmann::ordered_json updatedAccounts = nlohmann::ordered_json::array();

        Account* account = getAccount(inId);

        if (account == nullptr)
        {
            return;
        }

        if (!account->isOwnedBy(m_selectedUser))
        {
            return;
        }

        account->edit(
            inName,
            inClosingDay,
            inLimit,
            inType,
            inPrimaryColor,
            inSecondaryColor
        );

        emit onAccountsUpdate();

        m_selectedUser->editAccount(account);

        writeAccounts();
    }

    void Internal::deleteAccount(std::uint32_t inId)
    {
        if (m_selectedUser == nullptr)
        {
            return;
        }

        auto iterator = std::find_if(
            m_accounts.begin(),
            m_accounts.end(),
            [=](Account* account) { return account->getId() == inId; }
        );

        if (iterator == m_accounts.end())
        {
            return;
        }

        std::uint32_t index = iterator - m_accounts.begin();

        Account* account = m_accounts[index];

        if (account == nullptr)
        {
            return;
        }

        m_selectedUser->deleteAccount(account);

        if (account->isOwnedBy(m_selectedUser))
        {
            for (User* user : getUsers(account->getSharedUserIds()))
            {
                user->deleteAccount(account);
            }

            account->remove();

            delete account;

            m_accounts.removeAt(index); 
        }

        emit onAccountsUpdate();

        writeAccounts();
    }

    void Internal::mergeAccounts(
        std::uint32_t inSourceId,
        std::uint32_t inTargedId
    )
    {
        if (inSourceId == inTargedId)
        {
            return;
        }

        Account* sourceAccount = getAccount(inSourceId);
        Account* targetAccount = getAccount(inTargedId);

        if (sourceAccount == nullptr || targetAccount == nullptr)
        {
            return;
        }

        if (
            !sourceAccount->isOwnedBy(m_selectedUser->getId()) ||
            targetAccount->isOwnedBy(m_selectedUser->getId())
        )
        {
            return;
        }

        targetAccount->addPurchases(sourceAccount->getPurchases());

        m_selectedUser->removeAccount(sourceAccount);
        m_selectedUser->addAccount(targetAccount);

        if (m_selectedAccount->getId() == sourceAccount->getId())
        {
            deselect();
        }

        removeAccount(sourceAccount);

        emit onAccountsUpdate();

        writeAccounts();

        delete sourceAccount;
    }

    void Internal::select(std::uint32_t inId)
    {
        Account* account = getAccount(inId);

        if (account == nullptr)
        {
            return;
        }

        if (m_selectedAccount)
        {
            if (m_selectedAccount->getId() == account->getId())
            {
                return;
            }

            deselect();
        }

        m_selectedAccount = account;
        m_selectedAccount->refreshHistory();

        emit onSelectAccountUpdate();
    }

    void Internal::deselect()
    {
        if (m_selectedAccount == nullptr)
        {
            return;
        }

        m_selectedAccount->clearHistory();
        m_selectedAccount = nullptr;

        emit onSelectAccountUpdate();
    }

    void Internal::updateTheme(Colors::Theme inTheme)
    {
        m_colorsTheme = inTheme;

        writeSettings();

        reloadTheme();

        emit onThemeUpdate();

        updateShowcaseTheme(m_colorsTheme);
    }

    void Internal::updateShowcaseTheme(Colors::Theme inTheme)
    {
        m_showcaseColorsTheme = inTheme;

        reloadShowcaseTheme();

        emit onShowcaseThemeUpdate();
    }

    QDate Internal::addMonths(const QDate& inDate, int inMonths)
    {
        return inDate.addMonths(inMonths);
    }

    bool Internal::isSameDate(const QDate& inDateA, const QDate& inDateB)
    {
        return inDateA.daysTo(inDateB) == 0;
    }

    QString Internal::getLongDate(const QDate& inDate)
    {
        return inDate.toString("dd/MM/yyyy");
    }

    QString Internal::getLongMonth(const QDate& inDate)
    {
        return QLocale(QLocale::English).toString(
            inDate,
            "MMMM"
        );
    }

    float Internal::getDueAmount(const QList<Purchase*>& inPurchases)
    {
        float result = 0;

        for(Purchase* purchase : inPurchases)
        {
            result += purchase->getInstallmentValue();
        }

        return result;
    }

    QList<QString> Internal::getAccountTypes()
    {
        QList<QString> result{};

        for (auto [key, value] : ACCOUNT_TYPES)
        {
            result.push_back(QString::fromStdString(key));
        }

        std::sort(
            result.begin(),
            result.end(),
            [](QString& a, QString& b) { return Account::getTypeValue(a) < Account::getTypeValue(b); }
        );

        return result;
    }

    QString Internal::getAccountTypeName(Account::Type inType)
    {
        return Account::getTypeName(inType);
    }

    QList<QString> Internal::getPurchaseTypes()
    {
        QList<QString> result{};

        for (auto [key, value] : PURCHASE_TYPES)
        {
            result.push_back(QString::fromStdString(key));
        }

        std::sort(
            result.begin(),
            result.end(),
            [](QString& a, QString& b) { return Purchase::getTypeValue(a) < Purchase::getTypeValue(b); }
        );

        return result;
    }

    QString Internal::getPurchaseTypeName(Purchase::Type inType)
    {
        return Purchase::getTypeName(inType);
    }

    std::uint32_t Internal::getMinStatementClosingDay()
    {
        return MIN_STATEMENT_CLOSING_DAY;
    }

    std::uint32_t Internal::getMaxStatementClosingDay()
    {
        return MAX_STATEMENT_CLOSING_DAY;
    }

    std::uint32_t Internal::getMinInstallmentCount()
    {
        return MIN_INSTALLMENT_COUNT;
    }

    std::uint32_t Internal::getMaxInstallmentCount()
    {
        return MAX_INSTALLMENT_COUNT;
    }

    void Internal::clear(QList<void*> inList, bool willDelete)
    {
        if (willDelete)
        {
            for (std::uint32_t i = 0; i < inList.size(); i++)
            {
                delete inList[i];
            }
        }

        inList.clear();
    }

    void Internal::createFiles()
    {
        for (const char* fileName : FILE_NAMES)
        {
            if (FileSystem::doesFileExist(fileName))
            {
                continue;
            }

            if (fileName == SETTINGS_FILE_NAME)
            {
                updateTheme(m_colorsTheme);

                continue;
            }

            std::ofstream stream(fileName);
            stream << std::setw(4) << nlohmann::json::array() << std::endl;
            stream.close();
        }
    }

    void Internal::loadUsers()
    {
        if (!FileSystem::doesFileExist(USER_FILE_NAME))
        {
            return;
        }

        std::ifstream file(USER_FILE_NAME);
        nlohmann::json users = nlohmann::json::parse(file);

        if (!users.is_array())
        {
            return;
        }

        for (auto& it : users.items())
        {
            User* user = new User();
            user->fromJSON(it.value());

            m_users.push_back(user);
        }
    }

    void Internal::setUsersAccounts()
    {
        for (User* user : m_users)
        {
            QList<Account*> userAccounts {};

            for (Account* account : m_accounts)
            {
                if (!account->isOwnedBy(user) && !account->isSharingWith(user))
                {
                    continue;
                }

                userAccounts.push_back(account);
            }

            user->setAccounts(userAccounts);
        }
    }

    void Internal::loadAccounts()
    {
        if (!FileSystem::doesFileExist(ACCOUNT_FILE_NAME))
        {
            return;
        }

        std::ifstream file(ACCOUNT_FILE_NAME);
        nlohmann::json accounts = nlohmann::json::parse(file);

        if (!accounts.is_array())
        {
            return;
        }

        for (auto& it : accounts.items())
        {
            Account* account = new Account();
            account->fromJSON(it.value());

            if (getUser(account->getUserId()) == nullptr)
            {
                delete account;

                continue;
            }

            m_accounts.push_back(account);
        }

        sortAccounts();
    }

    void Internal::sortAccounts()
    {
        std::sort(
            m_accounts.begin(),
            m_accounts.end(),
            [](Account* a, Account* b) { return a->getId() < b->getId(); }
        );
    }

    void Internal::writeAccounts()
    {
        if (!FileSystem::doesFileExist(ACCOUNT_FILE_NAME))
        {
            return;
        }

        nlohmann::ordered_json accounts = nlohmann::ordered_json::array();

        for (Account* account : m_accounts)
        {
            accounts.push_back(account->toJSON());
        }

        std::ofstream stream(ACCOUNT_FILE_NAME);
        stream << std::setw(4) << accounts << std::endl;
    }

    void Internal::addAccount(Account* inAccount)
    {
        m_accounts.push_back(inAccount);

        sortAccounts();

        emit onAccountsUpdate();
    }

    void Internal::removeAccount(Account* inAccount)
    {
        m_accounts.removeAt(
            std::find_if(
                m_accounts.begin(),
                m_accounts.end(),
                [inAccount](Account* _) { return _->getId() == inAccount->getId(); }
            ) - m_accounts.begin()
        );

        emit onAccountsUpdate();
    }

    void Internal::loadSettings()
    {
        if (!FileSystem::doesFileExist(SETTINGS_FILE_NAME))
        {
            return;
        }

        std::ifstream file(SETTINGS_FILE_NAME);
        nlohmann::json settings = nlohmann::json::parse(file);

        if (!settings.is_object())
        {
            return;
        }

        bool hasColorTheme = settings.find("colorTheme") != settings.end() || settings.at("colorTheme").is_number_unsigned();
        updateTheme(hasColorTheme ? (Colors::Theme) settings.at("colorTheme") : m_colorsTheme);
    }

    void Internal::writeSettings()
    {
        std::ifstream file(SETTINGS_FILE_NAME);
        nlohmann::json settings = FileSystem::doesFileExist(SETTINGS_FILE_NAME) ? 
            nlohmann::json::parse(file):
            nlohmann::json::object();

        settings["colorTheme"] = (int) m_colorsTheme;

        // Write
        std::ofstream stream(SETTINGS_FILE_NAME);
        stream << std::setw(4) << settings << std::endl;
    }

    void Internal::reloadTheme()
    {
        switch (m_colorsTheme)
        {
        case Colors::Theme::Dark:
            m_colors->setBackgroundColor("#0C1017");
            m_colors->setForegroundColor("#08374A");
            m_colors->setLightColor(     "#006A74");
            m_colors->setDarkColor(      "#049E84");

            break;

        case Colors::Theme::Light:
        default:
            m_colors->setBackgroundColor("#E1F7F5");
            m_colors->setForegroundColor("#D9D9D9");
            m_colors->setLightColor(     "#829887");
            m_colors->setDarkColor(      "#39473C");

            break;
        }
    }

    void Internal::reloadShowcaseTheme()
    {
        switch (m_showcaseColorsTheme)
        {
        case Colors::Theme::Dark:
            m_showcaseColors->setBackgroundColor("#0C1017");
            m_showcaseColors->setForegroundColor("#164457");
            m_showcaseColors->setLightColor(     "#008e9c");
            m_showcaseColors->setDarkColor(      "#049E84");

            break;

        case Colors::Theme::Light:
        default:
            m_showcaseColors->setBackgroundColor("#E1F7F5");
            m_showcaseColors->setForegroundColor("#D9D9D9");
            m_showcaseColors->setLightColor(     "#829887");
            m_showcaseColors->setDarkColor(      "#39473C");

            break;
        }
    }

    void Internal::normalizePurchases()
    {
        if (!FileSystem::doesFileExist(PURCHASE_FILE_NAME))
        {
            return;
        }

        std::ifstream file(PURCHASE_FILE_NAME);

        nlohmann::json purchases    = nlohmann::json::parse(file);
        nlohmann::json newPurchases = nlohmann::json::array();

        if (!purchases.is_array())
        {
            return;
        }

        bool didNormalize = false;

        for (auto& it : purchases.items())
        {
            auto purchase = it.value();

            if (purchase.find("userId") != purchase.end())
            {
                newPurchases.push_back(purchase);

                continue;
            }

            Account* account = getAccount((std::uint32_t) purchase.at("accountId"));

            if (account == nullptr)
            {
                newPurchases.push_back(purchase);

                continue;
            }

            User* buyer = getUser(account->getUserId());

            if (buyer == nullptr)
            {
                newPurchases.push_back(purchase);

                continue;
            }

            newPurchases.push_back(
                {
                    { "id",           purchase.at("id") },
                    { "userId",       buyer->getId() },
                    { "accountId",    purchase.at("accountId") },
                    { "name",         purchase.at("name") },
                    { "description",  purchase.at("description") },
                    { "date",         purchase.at("date") },
                    { "type",         purchase.at("type") },
                    { "value",        purchase.at("value") },
                    { "installments", purchase.at("installments") }
                }
            );

            didNormalize = true;
        }

        if (!didNormalize)
        {
            return;
        }

        // Write
        std::ofstream stream(PURCHASE_FILE_NAME);
        stream << std::setw(4) << newPurchases << std::endl;
    }
}