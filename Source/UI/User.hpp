#pragma once

#include <QtCore>
#include <QColor>
#include <QImage>

#include <nlohmann/json.hpp>

namespace Financy
{
    class User : public QObject
    {
        Q_OBJECT

        Q_PROPERTY(
            QString firstName
            MEMBER m_firstName
        )
        Q_PROPERTY(
            QString lastName
            MEMBER m_lastName
        )
        Q_PROPERTY(
            QString picture
            MEMBER m_picture
        )
        Q_PROPERTY(
            QColor primaryColor
            MEMBER m_primaryColor
        )
        Q_PROPERTY(
            QColor secondaryColor
            MEMBER m_secondaryColor
        )

    public:
        User();
        ~User() = default;

        User& operator=(const User&) = default;

    public:
        void fromJSON(const nlohmann::json& inData);

    public:
        uint32_t getId();
        void setId(uint32_t inId);

        QString getFirstName();
        void setFirstName(const QString& inFirstName);

        QString getLastName();
        void setLastName(const QString& inLastName);

        QString getPicture();
        void setPicture(const QUrl& inUrl);
        void setPicture(const QString& inPicture);

        void setColorsFromPicture();

        QColor getPrimaryColor();
        void setPrimaryColor(const QColor& inColor);

        QColor getSecondaryColor();
        void setSecondaryColor(const QColor& inColor);

    private:
        uint32_t m_id;

        QString m_firstName;
        QString m_lastName;
        QString m_picture; // Base64

        QColor m_primaryColor;
        QColor m_secondaryColor;
    };
}