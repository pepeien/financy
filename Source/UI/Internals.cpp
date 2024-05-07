#include "Internals.hpp"

#include <iostream>
#include <fstream>

#include <QtDebug>
#include <QFileDialog>

#include <nlohmann/json.hpp>

#include <base64.hpp>

#include "Core/FileSystem.hpp"
#include "Core/Helper.hpp"

namespace Financy
{
    Internals::Internals(QObject* parent)
        : QObject(parent),
        m_colors(new Colors(parent))
    {
        updateTheme(Colors::Theme::Light);
        setupUsers();
    }

    Internals::~Internals()
    {
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

    void Internals::updateTheme(Colors::Theme inTheme)
    {
        if (!m_colors)
        {
            return;
        }

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

        onThemeUpdate();
    }

    bool Internals::addUser(
        const QString& inFirstName,
        const QString& inLastName,
        const QUrl& inPicture
    )
    {
        if (inFirstName.isEmpty() || inLastName.isEmpty() || inPicture.isEmpty())
        {
            return false;
        }

        if (inPicture.toString().toStdString().find("qrc://") != std::string::npos)
        {
            return false;
        }

        User* user = new User();
        user->setId(m_users.size());
        user->setFirstName(inFirstName);
        user->setLastName(inLastName);

        std::string filePath = Helper::splitString(
            inPicture.toString().toStdString(),
            "file:///"
        )[1];

        std::vector<std::string> splittedFilepath = Helper::splitString(
            filePath,
            "."
        );
        std::string fileExtension = splittedFilepath[splittedFilepath.size() - 1];

        std::vector<char> raw = FileSystem::readFile(filePath);
        std::string sRaw(raw.begin(), raw.end());

        user->setPicture(
            QString::fromLatin1(
                "data:image/" + fileExtension + ";base64," + base64::to_base64(sRaw)
            )
        );

        m_users.push_back(user);

        writeUser(user);

        onUsersUpdate();

        return true;
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
            Financy::User* user = new Financy::User();
            user->fromJSON(it.value());

            m_users.push_back(user);
        }
    }

    void Internals::writeUser(User* inUser)
    {
        if (!FileSystem::doesFileExist(USER_FILE_NAME))
        {
            return;
        }

        std::vector<char> userRaw = FileSystem::readFile(USER_FILE_NAME);

        nlohmann::json user = {
            { "id", inUser->getId() },
            { "firstName", inUser->getFirstName().toStdString() },
            { "lastName", inUser->getLastName().toStdString() },
            { "picture", inUser->getPicture().toStdString() }
        };

        std::ifstream file(USER_FILE_NAME);
        nlohmann::json users = nlohmann::json::parse(file);
        users.push_back(user);

        // Write
        std::ofstream stream(USER_FILE_NAME);
        stream << std::setw(4) << users << std::endl;
    }
}