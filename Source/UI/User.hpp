#pragma once

#include <QtCore>
#include <QColor>
#include <QImage>

#include <rapidjson/document.h>

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

    public:
        void fromJSON(const rapidjson::GenericObject<false, rapidjson::Value>& inData);

    public:
        uint32_t getId();

        QString getFirstName();
        void setFirstName(const QString& inFirstName);

        QString getLastName();
        void setLastName(const QString& inLastName);

        QImage getPicture();
        void setPicture(const QString& inPicture);

    private:
        void setDominantColors();

    private:
        uint32_t m_id;

        QString m_firstName;
        QString m_lastName;
        QString m_picture; // Base64

        QColor m_primaryColor;
        QColor m_secondaryColor;
    };
}