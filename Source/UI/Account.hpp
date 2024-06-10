#pragma once

#include <QtCore>
#include <QColor>

#include <nlohmann/json.hpp>

#include "Purchase.hpp"
#include "Statement.hpp"

namespace Financy
{
    class Account : public QObject
    {
        Q_OBJECT

        // Properties
        Q_PROPERTY(
            std::uint32_t id
            MEMBER m_id
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QString name
            MEMBER m_name
            NOTIFY onEdit
        )
        Q_PROPERTY(
            Type type
            MEMBER m_type
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
        Q_PROPERTY(
            QList<Statement*> history
            MEMBER m_history
            NOTIFY onEdit
        )

        // Stats
        Q_PROPERTY(
            float usedLimit
            READ getUsedLimit
            NOTIFY onEdit
        )
        Q_PROPERTY(
            float dueAmount
            READ getDueAmount
            NOTIFY onEdit
        )

    // Types
    public:
        enum class Type
        {
            Expense = 0,
            Saving  = 1
        };
        Q_ENUM(Type)

    signals:
        void onEdit();

    public:
        Account();
        ~Account() = default;

        Account& operator=(const Account&) = default;

    public slots:
        bool hasFullyPaid(Purchase* inPurchase);
        std::uint32_t getPaidInstallments(Purchase* inPurchase);
        std::uint32_t getPaidInstallments(Purchase* inPurchase, const QDate& inStatementDate);
        std::uint32_t getRemainingInstallments(Purchase* inPurchase);

        float getRemainingValue(Purchase* inPurchase);

        void createPurchase(
            const QString& inName,
            const QString& inDescription,
            const QString& inDate,
            const QString& inType,
            const QString& inValue,
            const QString& inInstallments
        );
        void editPurchase(
            std::uint32_t inId,
            const QString& inName,
            const QString& inDescription,
            const QString& inDate,
            const QString& inType,
            const QString& inValue,
            const QString& inInstallments
        );
        void deletePurchase(std::uint32_t inId);

        QList<Statement*> getPurchases(const QDate& inDate);
        QList<Purchase*> getSubscriptions(const QDate& inDate);

    public:
        void fromJSON(const nlohmann::json& inData);
        nlohmann::ordered_json toJSON();

    public:
        std::uint32_t getId();
        void setId(std::uint32_t inId);
    
        std::uint32_t getUserId();
        void setUserId(std::uint32_t inId);

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

        void edit(
            const QString& inName,
            const QString& inClosingDay,
            const QString& inLimit,
            const QString& inType,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );
        void remove();

        // Stats
        float getUsedLimit();
        float getRemainingLimit();
        float getDueAmount();
        float getDueAmount(Purchase::Type inType);

    private:
        QDate getEarliestStatementDate();
        QDate getLatestStatementDate();

        void sortPurchases();
        void refreshPurchases();

        void sortHistory();
        void refreshHistory();

        void deletePurchaseFromFile(std::uint32_t inId);
        void deletePurchaseFromMemory(std::uint32_t inId);

        void removeFromFile();
        void removePurchases();

    private:
        std::uint32_t m_id;
        std::uint32_t m_userId;

        QString m_name;
        std::uint32_t m_closingDay;
        Type m_type;

        float m_limit;
        QList<Purchase*> m_purchases;

        QColor m_primaryColor;
        QColor m_secondaryColor;

        QList<Statement*> m_history;
    };
}