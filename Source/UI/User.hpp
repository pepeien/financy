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

        // Finances
        Q_PROPERTY(
            QList<Account*> cards
            MEMBER m_cards
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QList<Account*> goals
            MEMBER m_goals
            NOTIFY onEdit
        )

    public:
        User();
        ~User();

        User& operator=(const User&) = default;

    signals:
        void onEdit();

    public slots:
        QString getFullName();

        void createAccount(
            const QString& inName,
            const QString& inClosingDay,
            const QString& inLimit,
            const QString& inType,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );

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

        QList<Account*> getCards();
        void setCards(const QList<Account*>& inCards);
        
        QList<Account*> getGoals();
        void setGoals(const QList<Account*>& inGoals);

        void edit(
            const QString& inFirstName,
            const QString& inLastName,
            const QUrl& inPicture,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );

    private:
        QString formatPicture(const QUrl& inUrl);

        void fetchAccounts();

    private:
        // consts
        std::string ACCOUNT_FILE_NAME = "Accounts.json";

        uint32_t m_id;

        QString m_firstName;
        QString m_lastName;
        QString m_picture; // Base64

        QColor m_primaryColor;
        QColor m_secondaryColor;

        QList<Account*> m_cards;
        QList<Account*> m_goals;
    };
}