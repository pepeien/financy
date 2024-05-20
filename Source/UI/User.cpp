#include "User.hpp"

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>

#include <cvmatandqimage.h>

#include <base64.hpp>

#include "Core/FileSystem.hpp"
#include "Core/Helper.hpp"

namespace Financy
{
    User::User()
        : m_id(0),
        m_firstName(""),
        m_lastName(""),
        m_picture(""),
        m_primaryColor("#FFFFFF"),
        m_secondaryColor("#000000")
    {}

    User::~User()
    {
        for (auto card : m_cards)
        {
            delete card;
        }

        for (auto goals : m_goals)
        {
            delete goals;
        }
    }

    void User::fromJSON(const nlohmann::json& inData)
    {
        // Data'
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

        // Colors
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

        // Finances
        if (inData.find("cards") != inData.end())
        {
            auto& cards = inData.at("cards");

            if (cards.is_array())
            {
                for (auto& it : cards.items())
                {
                    Account* card = new Account();
                    card->fromJSON(it.value());

                    m_cards.push_back(card);
                }
            }
        }

        if (inData.find("goals") != inData.end())
        {
            auto& goals = inData.at("goals");

            if (goals.is_array())
            {
                for (auto& it : goals.items())
                {
                    Account* goal = new Account();
                    goal->fromJSON(it.value());

                    m_goals.push_back(goal);
                }
            }
        }
    }

    nlohmann::json User::toJSON()
    {
        return {
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

    QList<Account*> User::getCards()
    {
        return m_cards;
    }

    void User::setCards(const QList<Account*>& inCards)
    {
        m_cards = inCards;
    }
        
    QList<Account*> User::getGoals()
    {
        return m_goals;
    }

    void User::setGoals(const QList<Account*>& inGoals)
    {
        m_goals = inGoals;
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

        onEdit();
    }

    QString User::formatPicture(const QUrl& inUrl)
    {
        if (inUrl.toString().toStdString().find("qrc://") != std::string::npos)
        {
            return "";
        }

        std::vector<std::string> splittedUrl = Helper::splitString(
            inUrl.toString().toStdString(),
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

        return QString::fromLatin1(
            "data:image/" + fileExtension + ";base64," + base64::to_base64(sRaw)
        );
    }
}