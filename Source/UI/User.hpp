#pragma once

#include <QtCore>
#include <QColor>
#include <QImage>

#include <nlohmann/json.hpp>

#include "UI/Account.hpp"

namespace Financy
{
    class User : public QObject
    {
        Q_OBJECT

        // Data
        Q_PROPERTY(
            std::uint32_t id
            MEMBER m_id
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QString firstName
            MEMBER m_firstName
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QString lastName
            MEMBER m_lastName
            NOTIFY onEdit
        )

        // Looks
        Q_PROPERTY(
            QString picture
            MEMBER m_picture
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QColor primaryColor
            MEMBER m_primaryColor
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QColor secondaryColor
            MEMBER m_secondaryColor
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QList<Account*> accounts
            MEMBER m_accounts
            NOTIFY onEdit
        )

        // Stats
        Q_PROPERTY(
            QVariantMap expenseMap
            READ getExpenseMap
            NOTIFY onEdit
        )
        Q_PROPERTY(
            float dueAmount
            READ getDueAmount
            NOTIFY onEdit
        )

    public:
        User();
        ~User() = default;

        User& operator=(const User&) = default;

    signals:
        void onEdit();

    public slots:
        QString getFullName();

        void refresh();

        QVariantMap getExpenseMap();
        QVariantMap getExpenseMap(int inUserId);

        float getDueAmount();
        float getDueAmount(int inUserId);

    public:
        void fromJSON(const nlohmann::json& inData);
        nlohmann::ordered_json toJSON();

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

        QColor getPrimaryColor();
        void setPrimaryColor(const QColor& inColor);

        QColor getSecondaryColor();
        void setSecondaryColor(const QColor& inColor);

        Account* getAccount(std::uint32_t inId);

        QList<Account*> getAccounts();
        QList<Account*> getAccounts(Account::Type inType);
        void setAccounts(const QList<Account*>& inAccounts);

        void edit(
            const QString& inFirstName,
            const QString& inLastName,
            const QUrl& inPicture,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );
        void remove();

        void login();
        void logout();

        // Account
        void addAccount(Account* inAccount);
        void editAccount(Account* inAccount);
        void deleteAccount(Account* inAccount);
        void removeAccount(Account* inAccount);

    private:
        QString formatPicture(const QUrl& inUrl);

        void sortAccounts();

        void removeFromFile();
        void removeAccounts();

    private:
        bool m_fetchedAccounts;

        uint32_t m_id;

        QString m_firstName;
        QString m_lastName;
        QString m_picture; // Base64

        QColor m_primaryColor;
        QColor m_secondaryColor;

        QList<Account*> m_accounts;
    };
}