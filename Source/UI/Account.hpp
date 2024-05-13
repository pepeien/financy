#pragma once

#include <QtCore>
#include <QColor>

#include <nlohmann/json.hpp>

#include "Purchase.hpp"

namespace Financy
{
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

    signals:
        void onEdit();

    public:
        Account();
        ~Account() = default;

        Account& operator=(const Account&) = default;

    public slots:
        float getUsedLimit();
        float getRemainingLimit();

        int getPaidInstallments(Purchase* inPurchase);
        int getRemainingInstallments(Purchase* inPurchase);

        float getRemainingValue(Purchase* inPurchase);

        float getDueAmount();

    public:
        void fromJSON(const nlohmann::json& inData);

    public:
        QString getName();
        void setName(const QString& inName);

        std::uint32_t getClosingDay();
        void setClosingDay(std::uint32_t inClosingDay);

        float getLimit();
        void setLimit(float inLimit);

        QList<Purchase*> getPurchases();
        void setPurchases(const QList<Purchase*>& inPurchases);

        bool recoversLimitOnInstallmentPayment();
        void setRecoversLimitOnInstallmentPayment(bool bInRecoversLimitOnInstallmentPayment);

        QColor getPrimaryColor();
        void setPrimaryColor(const QColor& inColor);

        QColor getSecondaryColor();
        void setSecondaryColor(const QColor& inColor);

    private:
        QString m_name;
        std::uint32_t m_closingDay;

        float m_limit;
        QList<Purchase*> m_purchases;
        bool m_bRecoversLimitOnInstallmentPayment;

        QColor m_primaryColor;
        QColor m_secondaryColor;
    };
}