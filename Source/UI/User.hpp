#pragma once

#include <QtCore>

#include "ColorSchene.hpp"

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
        QString getFirstName();
        void setFirstName(const QString& inFirstName);

        QString getLastName();
        void setLastName(const QString& inLastName);

        QImage getPicture();
        void setPicture(const QString& inPicture);

    private:
        void setDominantColors();

    private:
        QString m_firstName;
        QString m_lastName;
        QString m_picture; // Base64
        QColor m_primaryColor;
        QColor m_secondaryColor;
    };
}