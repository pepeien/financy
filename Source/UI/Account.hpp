#pragma once

#include <QtCore>
#include <QColor>

#include <nlohmann/json.hpp>

#include "Purchase.hpp"

namespace Financy
{
    struct Statement
    {
        Q_GADGET

        Q_PROPERTY(
            QDate date
            MEMBER m_date
        )
        Q_PROPERTY(
            QList<Purchase*> purchases
            MEMBER m_purchases
        )
        Q_PROPERTY(
            QList<Purchase*> subscriptions
            MEMBER m_subscriptions
        )
        Q_PROPERTY(
            float dueAmount
            MEMBER m_dueAmount
        )

    public slots:
        QList<Statement> getDateBasedHistory();

    public:
        QDate m_date;
        QList<Purchase*> m_purchases;
        QList<Purchase*> m_subscriptions;
        float m_dueAmount;
    };

    class Account : public QObject
    {
        Q_OBJECT

        // Properties
        Q_PROPERTY(
            QString name
            MEMBER m_name
            NOTIFY onEdit
        )
        Q_PROPERTY(
            std::uint32_t closingDay
            MEMBER m_closingDay
            NOTIFY onEdit
        )
        Q_PROPERTY(
            float limit
            MEMBER m_limit
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QList<Purchase*> purchases
            MEMBER m_purchases
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

    // Types
    public:
        enum class Type
        {
            Expense = 0,
            Saving  = 1
        };

    signals:
        void onEdit();

    public:
        Account();
        ~Account() = default;

        Account& operator=(const Account&) = default;

    public slots:
        float getUsedLimit();
        float getRemainingLimit();

        bool hasFullyPaid(Purchase* inPurchase);
        int getPaidInstallments(Purchase* inPurchase);
        int getPaidInstallments(Purchase* inPurchase, const QDate& inDate);
        int getRemainingInstallments(Purchase* inPurchase);

        float getRemainingValue(Purchase* inPurchase);

        float getDueAmount();

        QList<Statement> getHistory();

    public:
        void fromJSON(const nlohmann::json& inData);

    public:
        QString getName();
        void setName(const QString& inName);

        std::uint32_t getClosingDay();
        void setClosingDay(std::uint32_t inClosingDay);

        Type getType();
        void setType(Type inType);

        float getLimit();
        void setLimit(float inLimit);

        QList<Purchase*> getPurchases();
        void setPurchases(const QList<Purchase*>& inPurchases);

        QColor getPrimaryColor();
        void setPrimaryColor(const QColor& inColor);

        QColor getSecondaryColor();
        void setSecondaryColor(const QColor& inColor);

    private:
        QString m_name;
        std::uint32_t m_closingDay;
        Type m_type;

        float m_limit;
        QList<Purchase*> m_purchases;

        QColor m_primaryColor;
        QColor m_secondaryColor;
    };
}