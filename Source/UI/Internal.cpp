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

#include "Core/FileSystem.hpp"
#include "Core/Helper.hpp"

namespace Financy
{
    Internal::Internal(QObject* parent)
        : QObject(parent),
        m_colors(new Colors(parent)),
        m_showcaseColors(new Colors(parent))
    {
        loadSettings();
        loadUsers();
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
        ).toString();
    }

    QList<QColor> Internal::getUserColorsFromImage(const QString& inImage)
    {
        if (inImage.isEmpty() || inImage.toStdString().find("qrc://") != std::string::npos)
        {
            return { "#000000", "#FFFFFF" };
        }

        std::vector<std::string> splittedUrl = Helper::splitString(
            inImage.toStdString(),
            "file:///"
        );

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

    User* Internal::addUser(
        const QString& inFirstName,
        const QString& inLastName,
        const QUrl& inPicture,
        const QColor& inPrimaryColor,
        const QColor& inSecondaryColor
    )
    {
        if (inFirstName.isEmpty() || inLastName.isEmpty() || inPicture.isEmpty())
        {
            return nullptr;
        }

        User* user = new User();
        user->setId(                m_users.size());
        user->setFirstName(              inFirstName);
        user->setLastName(               inLastName);
        user->setPicture(         inPicture);
        user->setPrimaryColor(  inPrimaryColor);
        user->setSecondaryColor(inSecondaryColor);

        writeUser(user);

        m_users.push_back(user);

        onUsersUpdate();

        return user;
    }

    void Internal::removeUser(std::uint32_t inId)
    {
        int userCount = m_users.size();

        removeUserFromFile(  inId);
        removeUserFromMemory(inId);

        if (userCount == m_users.size())
        {
            return;
        }

        emit onUsersUpdate();
    }

    void Internal::login(User* inUser)
    {
        if (inUser == nullptr)
        {
            return;
        }

        if (m_selectedUser != nullptr && inUser->getId() == m_selectedUser->getId())
        {
            return;
        }

        m_selectedUser = inUser;

        onSelectUserUpdate();
    }

    void Internal::logout()
    {
        if (m_selectedUser == nullptr)
        {
            return;
        }

        m_selectedUser = nullptr;

        onSelectUserUpdate();
    }

    void Internal::updateTheme(Colors::Theme inTheme)
    {
        m_colorsTheme = inTheme;

        writeSettings();

        reloadTheme();
        onThemeUpdate();

        updateShowcaseTheme(m_colorsTheme);
    }

    void Internal::updateShowcaseTheme(Colors::Theme inTheme)
    {
        m_showcaseColorsTheme = inTheme;

        reloadShowcaseTheme();
        onShowcaseThemeUpdate();
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

        for (auto& it : users.items()) {
            User* user = new User();
            user->fromJSON(it.value());

            m_users.push_back(user);
        }
    }

    void Internal::writeUser(User* inUser)
    {
        nlohmann::json user = {
            { "id", inUser->getId() },
            { "firstName", inUser->getFirstName().toStdString() },
            { "lastName", inUser->getLastName().toStdString() },
            { "picture", inUser->getPicture().toStdString() },
            { "primaryColor", inUser->getPrimaryColor().name().toStdString() },
            { "secondaryColor", inUser->getSecondaryColor().name().toStdString()  }
        };

        std::ifstream file(USER_FILE_NAME);
        nlohmann::json users = FileSystem::doesFileExist(USER_FILE_NAME) ? 
            nlohmann::json::parse(file):
            nlohmann::json::array();
        users.push_back(user);

        // Write
        std::ofstream stream(USER_FILE_NAME);
        stream << std::setw(4) << users << std::endl;
    }

    void Internal::removeUserFromFile(std::uint32_t inId)
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

        int index = 0;
        int lastSize = storedUsers.size();

        for (auto& it : storedUsers.items())
        {
            if ((std::uint32_t) it.value().at("id") != inId)
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

    void Internal::removeUserFromMemory(std::uint32_t inId)
    {
        auto iterator = std::find_if(
            m_users.begin(),
            m_users.end(),
            [=](User* user) { return user->getId() == inId; }
        );

        if (iterator == m_users.end())
        {
            return;
        }

        m_users.removeAt(iterator - m_users.begin());
    }

    void Internal::loadSettings()
    {
        if (!FileSystem::doesFileExist(SETTINGS_FILE_NAME))
        {
            updateTheme(m_colorsTheme);

            return;
        }

        std::ifstream file(SETTINGS_FILE_NAME);
        nlohmann::json settings = nlohmann::json::parse(file);

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
            m_showcaseColors->setForegroundColor("#08374A");
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
}