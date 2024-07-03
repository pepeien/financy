#include "User.hpp"

#include <iostream>
#include <fstream>

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>

#include <cvmatandqimage.h>

#include <base64.hpp>

#include "Base.hpp"
#include "Core/FileSystem.hpp"
#include "Core/Helper.hpp"

namespace Financy
{
    User::User()
        : m_fetchedAccounts(false),
        m_id(0),
        m_firstName(""),
        m_lastName(""),
        m_picture(""),
        m_primaryColor("#FFFFFF"),
        m_secondaryColor("#000000")
    {}

    void User::fromJSON(const nlohmann::json& inData)
    {
        setId(
            inData.find("id") != inData.end() ?
                inData.at("id").is_number_unsigned() ?
                    (std::uint32_t) inData.at("id") : 0
                :
                0
        );
        setFirstName(
            inData.find("firstName") != inData.end() ?
                QString::fromStdString((std::string) inData.at("firstName")) :
                ""
        );
        setLastName(
            inData.find("lastName") != inData.end() ?
                QString::fromStdString((std::string) inData.at("lastName")) :
                ""
        );
        setPicture(
            inData.find("picture") != inData.end() ?
                QString::fromStdString((std::string) inData.at("picture")) :
                ""
        );
        setPrimaryColor(
            inData.find("primaryColor") != inData.end() ?
                QString::fromStdString((std::string) inData.at("primaryColor")) :
                "#FFFFFF"
        );
        setSecondaryColor(
            inData.find("secondaryColor") != inData.end() ?
                QString::fromStdString((std::string) inData.at("secondaryColor")) :
                "#000000"
        );
    }

    nlohmann::ordered_json User::toJSON()
    {
        return nlohmann::ordered_json{
            { "id",             m_id },
            { "firstName",      m_firstName.toStdString() },
            { "lastName",       m_lastName.toStdString() },
            { "picture",        m_picture.toStdString() },
            { "primaryColor",   m_primaryColor.name().toStdString() },
            { "secondaryColor", m_secondaryColor.name().toStdString() }
        };
    }

    QString User::getFullName()
    {
        return m_firstName + " " + m_lastName;
    }

    void User::refresh()
    {
        emit onEdit();
    }

    uint32_t User::getId()
    {
        return m_id;
    }

    void User::setId(uint32_t inId)
    {
        m_id = inId;
    }

    QString User::getFirstName()
    {
        return m_firstName;
    }

    void User::setFirstName(const QString& inFirstName)
    {
        if (inFirstName.isEmpty())
        {
            return;
        }

        m_firstName = inFirstName;
    }

    QString User::getLastName()
    {
        return m_lastName;
    }

    void User::setLastName(const QString& inLastName)
    {
        if (inLastName.isEmpty())
        {
            return;
        }

        m_lastName = inLastName;
    }

    QString User::getPicture()
    {
        return m_picture;
    }

    void User::setPicture(const QUrl& inUrl)
    {
        QString image = formatPicture(inUrl);

        if (image.isEmpty())
        {
            return;
        }

        setPicture(image);
    }

    void User::setPicture(const QString& inPicture)
    {
        m_picture = inPicture;
    }

    QColor User::getPrimaryColor()
    {
        return m_primaryColor;
    }

    void User::setPrimaryColor(const QColor& inColor)
    {
        m_primaryColor = inColor;
    }

    QColor User::getSecondaryColor()
    {
        return m_secondaryColor;
    }

    void User::setSecondaryColor(const QColor& inColor)
    {
        m_secondaryColor = inColor;
    }

    Account* User::getAccount(std::uint32_t inId)
    {
        auto iterator = std::find_if(
            m_accounts.begin(),
            m_accounts.end(),
            [inId](Account* _) { return _->getId() == inId; }
        );

        if (iterator == m_accounts.end())
        {
            return nullptr;
        }

        return m_accounts[iterator - m_accounts.begin()];
    }

    QList<Account*> User::getAccounts()
    {
        return m_accounts;
    }

    QList<Account*> User::getAccounts(Account::Type inType)
    {
        QList<Account*> result{};

        for (Account* account : m_accounts)
        {
            if (account->getType() != inType)
            {
                continue;
            }

            result.push_back(account);
        }

        return result;
    }

    void User::setAccounts(const QList<Account*>& inAccounts)
    {
        m_accounts = inAccounts;

        sortAccounts();

        emit onEdit();
    }

    void User::edit(
        const QString& inFirstName,
        const QString& inLastName,
        const QUrl& inPicture,
        const QColor& inPrimaryColor,
        const QColor& inSecondaryColor
    )
    {
        if (m_firstName.compare(inFirstName) != 0)
        {
            m_firstName = inFirstName;
        }

        if (m_lastName.compare(inLastName) != 0)
        {
            m_lastName = inLastName;
        }

        if (m_picture.compare(inPicture.toString()) != 0)
        {
            QString picture = formatPicture(inPicture);

            if (picture.isEmpty())
            {
                return;
            }

            m_picture = picture;
        }

        if (m_primaryColor.name().compare(inPrimaryColor.name()) != 0)
        {
            m_primaryColor = inPrimaryColor;
        }

        if (m_secondaryColor.name().compare(inSecondaryColor.name()) != 0)
        {
            m_secondaryColor = inSecondaryColor;
        }

        emit onEdit();
    }

    void User::remove()
    {
        removeAccounts();
        removeFromFile();
    }

    QVariantMap User::getExpenseMap()
    {
        QDate now = QDate::currentDate();

        QMap<QString, float> map;

        for (Account* account : m_accounts)
        {
            if (account->getType() != Account::Type::Expense)
            {
                continue;
            }

            for (Purchase* purchase : account->getPurchases(now))
            {
                QString type = purchase->getTypeName();

                if (!map.contains(type))
                {
                    map.insert(type, 0);
                }

                map[type] += purchase->getInstallmentValue();
            }
        }

        QVariantMap result;

        for (QMap<QString, float>::iterator iterator = map.begin(); iterator != map.end(); iterator++)
        {
            result.insert(
                iterator.key(),
                iterator.value()
            );
        }

        return result;
    }

    float User::getDueAmount()
    {
        float result = 0;

        for (Account* expenseAccount : getAccounts(Account::Type::Expense))
        {
            result += expenseAccount->getDueAmount();
        }

        return result;
    }

    void User::login()
    {
        for (Account* account : m_accounts)
        {
            account->refreshPurchases();
        }
    }

    void User::logout()
    {
        for (Account* account : m_accounts)
        {
            account->clearHistory();
        }
    }

    void User::addAccount(Account* inAccount)
    {
        if (inAccount == nullptr)
        {
            return;
        }

        if (!inAccount->isOwnedBy(m_id))
        {
            inAccount->shareWith(m_id);
        }

        m_accounts.push_back(inAccount);

        sortAccounts();

        emit onEdit();
    }

    void User::editAccount(Account* inAccount)
    {
        emit onEdit();
    }

    void User::deleteAccount(Account* inAccount)
    {
        if (!inAccount)
        {
            return;
        }

        auto foundAccountIt = std::find_if(
            m_accounts.begin(),
            m_accounts.end(),
            [inAccount](Account* _) { return _->getId() == inAccount->getId(); }
        );

        if (foundAccountIt == m_accounts.end())
        {
            return;
        }

        if (inAccount->isSharingWith(m_id))
        {
            inAccount->withholdFrom(m_id);
        }

        m_accounts.removeAt(foundAccountIt - m_accounts.begin());

        emit onEdit();
    }

    void User::removeAccount(Account* inAccount)
    {
        m_accounts.removeAt(
            std::find_if(
                m_accounts.begin(),
                m_accounts.end(),
                [inAccount](Account* _) { return _->getId() == inAccount->getId(); }
            ) - m_accounts.begin()
        );
    }

    QString User::formatPicture(const QUrl& inUrl)
    {
        if (inUrl.isEmpty())
        {
            return "";
        }

        if (inUrl.toString().toStdString().find("qrc://") != std::string::npos)
        {
            return "";
        }

        #ifdef OS_WINDOWS
            std::vector<std::string> splittedUrl = Helper::splitString(
                inUrl.toString().toStdString(),
                "file:///"
            );
        #else
            std::vector<std::string> splittedUrl = Helper::splitString(
                inUrl.toString().toStdString(),
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

        return QString::fromLatin1(
            "data:image/" + fileExtension + ";base64," + base64::to_base64(sRaw)
        );
    }

    void User::sortAccounts()
    {
        std::sort(
            m_accounts.begin(),
            m_accounts.end(),
            [](Account* a, Account* b) { return a->getId() < b->getId(); }
        );
    }

    void User::removeFromFile()
    {
        // Remove from file
        if (!FileSystem::doesFileExist(USER_FILE_NAME))
        {
            return;
        }

        std::ifstream file(USER_FILE_NAME);

        nlohmann::json storedUsers = nlohmann::json::parse(file);

        if (storedUsers.size() < 0 || !storedUsers.is_array())
        {
            return;
        }

        std::uint32_t index  = 0;
        std::size_t lastSize = storedUsers.size();

        for (auto& it : storedUsers.items())
        {
            if ((std::uint32_t) it.value().at("id") != m_id)
            {
                index++;

                continue;
            }

            storedUsers.erase(index);

            break;
        }

        if (lastSize == storedUsers.size())
        {
            return;
        }

        std::ofstream stream(USER_FILE_NAME);
        stream << std::setw(4) << storedUsers << std::endl;
    }

    void User::removeAccounts()
    {
        m_accounts.clear();
    }
}