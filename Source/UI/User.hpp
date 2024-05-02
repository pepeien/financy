#pragma once

#include <QtCore>

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
    
    public:
        User();

    public:
        QString getFirstName();
        void setFirstName(const QString& inFirstName);

        QString getLastName();
        void setLastName(const QString& inLastName);

        QByteArray getPicture();
        void setPicture(const QString& inPicture);

    private:
        QString m_firstName;
        QString m_lastName;
        QString m_picture; // Base64
    };
}