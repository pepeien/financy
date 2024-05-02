#include "User.hpp"

namespace Financy
{
    User::User()
        : m_firstName(""),
        m_lastName(""),
        m_picture("")
    {}

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

    QByteArray User::getPicture()
    {
        return QByteArray::fromBase64(m_picture.toStdString().c_str(), QByteArray::Base64Encoding);
    }

    void User::setPicture(const QString& inPicture)
    {
        m_picture = inPicture;
    }
}