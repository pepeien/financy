#include "Internals.hpp"

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
    Internals::Internals(QObject* parent)
        : QObject(parent),
        m_colors(new Colors(parent)),
        m_showcaseColors(new Colors(parent))
    {
        updateTheme(Colors::Theme::Light);

        setupUsers();
    }

    Internals::~Internals()
    {
        for (QObject* user : m_users)
        {
            delete user;
        }

        delete m_colors;
    }

    QString Internals::openFileDialog(
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

    QList<QColor> Internals::getUserColorsFromImage(const QString& inImage)
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

    User* Internals::addUser(
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

    void Internals::login(User* inUser)
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

    void Internals::logout()
    {
        if (m_selectedUser == nullptr)
        {
            return;
        }

        m_selectedUser = nullptr;

        onSelectUserUpdate();
    }

    void Internals::updateTheme(Colors::Theme inTheme)
    {
        m_colorsTheme = inTheme;

        switch (inTheme)
        {
        case Colors::Theme::Dark:
            m_colors->setBackgroundColor("#0C1017");
            m_colors->setForegroundColor("#08374A");
            m_colors->setLightColor("#006A74");
            m_colors->setDarkColor("#049E84");

            break;

        case Colors::Theme::Light:
        default:
            m_colors->setBackgroundColor("#E1F7F5");
            m_colors->setForegroundColor("#D9D9D9");
            m_colors->setLightColor("#596B5D");
            m_colors->setDarkColor("#39473C");

            break;
        }

        updateShowcaseTheme(inTheme);

        onThemeUpdate();
    }

    void Internals::updateShowcaseTheme(Colors::Theme inTheme)
    {
        m_showcaseColorsTheme = inTheme;

        switch (inTheme)
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
            m_showcaseColors->setLightColor(     "#596B5D");
            m_showcaseColors->setDarkColor(      "#39473C");

            break;
        }

        onShowcaseThemeUpdate();
    }

    void Internals::setupUsers()
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

    void Internals::writeUser(User* inUser)
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
}