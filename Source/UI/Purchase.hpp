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
            bool bIsSubscription
            MEMBER m_bIsSubscription
            NOTIFY onEdit
        )

    signals:
        void onEdit();

    public:
        Purchase();
        ~Purchase() = default;

        Purchase& operator=(const Purchase&) = default;

    public slots:
        float getInstallmentValue();

    public:
        void fromJSON(const nlohmann::json& inData);

    public:
        QString getName();
        void setName(const QString& inName);

        QString getDescription();
        void setDescription(const QString& inDescription);

        QDate getDate();
        void setDate(const QDate& inDate);

        float getValue();
        void setValue(float inValue);

        int getInstallments();
        void setInstallments(int inInstallments);

        bool isSubscription();
        void setIsSubscription(bool inIsSubscription);

    private:
        QString m_name;
        QString m_description;
        QDate m_date;

        float m_value;
        int m_installments;

        bool m_bIsSubscription;
    };
}