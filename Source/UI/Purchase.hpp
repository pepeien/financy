#pragma once

#include <QtCore>
#include <QDate>

#include <nlohmann/json.hpp>

namespace Financy
{
    class Purchase : public QObject
    {
        Q_OBJECT

        // Properties
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
            int installments
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
            Utility       = 0, // Light, Water, Internet, Gas, School bills
            Subscription  = 1,
            Travel        = 2,
            Debt          = 3,
            Food          = 4,
            Other         = 5
        };
        Q_ENUM(Type)

    signals:
        void onEdit();

    public:
        Purchase();
        ~Purchase() = default;

        Purchase& operator=(const Purchase&) = default;

    public slots:
        bool hasDescription();

        float getInstallmentValue();

        QString getTypeName();

    public:
        void fromJSON(const nlohmann::json& inData);
        nlohmann::ordered_json toJSON();

    public:
        std::uint32_t getId();
        void setId(std::uint32_t inId);

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

        int getInstallments();
        void setInstallments(int inInstallments);

        // Subscription
        QDate getEndDate();
        void setEndDate(const QDate& inDate);

    private:
        std::uint32_t m_id;
        std::uint32_t m_accountId;

        QString m_name;
        QString m_description;
        QDate m_date;
        Type m_type;

        float m_value;
        int m_installments;

        // Subscription
        QDate m_endDate;
    };
}