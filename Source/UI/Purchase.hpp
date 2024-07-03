#pragma once

#include <unordered_map>

#include <QtCore>
#include <QDate>

#include <nlohmann/json.hpp>

namespace Financy
{
    class User;
    class Purchase : public QObject
    {
        Q_OBJECT

        // Properties
        Q_PROPERTY(
            std::uint32_t id
            MEMBER m_id
            NOTIFY onEdit
        )
        Q_PROPERTY(
            std::uint32_t userId
            MEMBER m_userId
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QString name
            MEMBER m_name
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QString description
            MEMBER m_description
            NOTIFY onEdit
        )
        Q_PROPERTY(
            QDate date
            MEMBER m_date
            NOTIFY onEdit
        )
        Q_PROPERTY(
            float value
            MEMBER m_value
            NOTIFY onEdit
        )
        Q_PROPERTY(
            std::uint32_t installments
            MEMBER m_installments
            NOTIFY onEdit
        )
        Q_PROPERTY(
            Type type
            MEMBER m_type
            NOTIFY onEdit
        )

    // Types
    public:
        enum class Type
        {
            Utility , // Light, Water, Internet, Gas, School bills
            Subscription,
            Transport,
            Debt,
            Food,
            Bill,
            Other
        };
        Q_ENUM(Type)

    signals:
        void onEdit();

    public:
        Purchase();
        ~Purchase() = default;

        Purchase& operator=(const Purchase&) = default;

    public:
        static Type getTypeValue(const QString& inName);
        static QString getTypeName(Type inType);

    public slots:
        bool isOwnedBy(std::uint32_t inUserId);

        bool isRecurring();

        bool hasDescription();

        float getInstallmentValue();
        QString getTypeName();

    public:
        void fromJSON(const nlohmann::json& inData);
        nlohmann::ordered_json toJSON();

    public:
        bool isOwnedBy(User* inUser);

        std::uint32_t getId();
        void setId(std::uint32_t inId);

        std::uint32_t getUserId();
        void setUserId(std::uint32_t inId);

        std::uint32_t getAccountId();
        void setAccountId(std::uint32_t inId);

        QString getName();
        void setName(const QString& inName);

        QString getDescription();
        void setDescription(const QString& inDescription);

        QDate getDate();
        void setDate(const QDate& inDate);

        Type getType();
        void setType(Type inType);

        float getValue();
        void setValue(float inValue);

        bool isFullyPaid(const QDate& inFinalDate, std::uint32_t inStatementClosingDay);
        std::uint32_t getPaidInstallments(const QDate& inFinalDate, std::uint32_t inStatementClosingDay);

        std::uint32_t getInstallments();
        void setInstallments(std::uint32_t inInstallments);

        // Subscription
        QDate getEndDate();
        void setEndDate(const QDate& inDate);

        void edit(
            const QString& inName,
            const QString& inDescription,
            const QDate& inDate,
            Type inType,
            float inValue,
            std::uint32_t inInstallments
        );

    private:
        std::uint32_t m_id;
        std::uint32_t m_userId;
        std::uint32_t m_accountId;

        QString m_name;
        QString m_description;
        QDate m_date;
        Type m_type;

        float m_value;
        std::uint32_t m_installments;

        // Subscription
        QDate m_endDate;
    };

    static std::unordered_map<std::string, Purchase::Type> PURCHASE_TYPES = {
        { "Debt",         Purchase::Type::Debt },
        { "Food",         Purchase::Type::Food},
        { "Subscription", Purchase::Type::Subscription },
        { "Transport",    Purchase::Type::Transport },
        { "Utility",      Purchase::Type::Utility },
        { "Bill",         Purchase::Type::Bill },
        { "Other",        Purchase::Type::Other }
    };
}