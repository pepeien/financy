#pragma once

#include <QtCore>

#include "Purchase.hpp"

namespace Financy
{
    class Statement : public QObject
    {
        Q_OBJECT

        Q_PROPERTY(
            QDate date
            MEMBER m_date
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QList<Purchase*> purchases
            MEMBER m_purchases
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QList<Purchase*> subscriptions
            MEMBER m_subscriptions
            NOTIFY onEdit
        )
        Q_PROPERTY(
            float dueAmount
            MEMBER m_dueAmount
            NOTIFY onEdit
        )

    public:
        Statement();
        ~Statement() = default;

        Statement& operator=(const Statement&) = default;

    signals:
        void onEdit();

    public slots:
        bool isCurrentStatement(const QDate& inDate);
        bool isFuture(const QDate& inDate);
        bool isSameYear(const QDate& inDate);

    public:
        void setDate(const QDate& inDate);
        QDate getDate();

        void setPurchases(const QList<Purchase*>& inPurchases);
        QList<Purchase*> getPurchases();

        void setSubscritions(const QList<Purchase*>& inSubscritions);
        QList<Purchase*> getSubscriptions();

        void setDueAmount(float inValue);
        float getDueAmount();

    private:
        QDate m_date;
        QList<Purchase*> m_purchases;
        QList<Purchase*> m_subscriptions;
        float m_dueAmount;
    };
}