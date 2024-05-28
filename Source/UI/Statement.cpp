#include "Statement.hpp"

namespace Financy
{
    Statement::Statement()
        : QObject(),
        m_date(QDate::currentDate()),
        m_purchases({}),
        m_subscriptions({}),
        m_dueAmount(0.0f)
    {}

    void Statement::setDate(const QDate& inDate)
    {
        m_date = inDate;
    }

    QDate Statement::getDate()
    {
        return m_date;
    }

    void Statement::setPurchases(const QList<Purchase*>& inPurchases)
    {
        m_purchases = inPurchases;
    }

    QList<Purchase*> Statement::getPurchases()
    {
        return m_purchases;
    }

    void Statement::setSubscritions(const QList<Purchase*>& inSubscritions)
    {
        m_subscriptions = inSubscritions;
    }

    QList<Purchase*> Statement::getSubscriptions()
    {
        return m_subscriptions;
    }

    void Statement::setDueAmount(float inValue)
    {
        m_dueAmount = inValue;
    }

    float Statement::getDueAmount()
    {
        return m_dueAmount;
    }

    void Statement::refreshDateBasedHistory()
    {
        m_dateBasedHistory = {};

        for (Purchase* purchase : m_purchases) {
            auto foundItem = std::find_if(
                m_dateBasedHistory.begin(),
                m_dateBasedHistory.end(),
                [purchase](Statement* _) { return _->getDate().daysTo(purchase->getDate()) == 0; }
            );

            int foundIndex = foundItem - m_dateBasedHistory.begin();

            if (foundItem == m_dateBasedHistory.end()) {
                foundIndex = m_dateBasedHistory.size();

                m_dateBasedHistory.push_back(new Statement());

                m_dateBasedHistory[foundIndex]->setDate(     purchase->getDate());
                m_dateBasedHistory[foundIndex]->setPurchases({});
            }

            QList<Purchase*> purchases = m_dateBasedHistory[foundIndex]->getPurchases();
            purchases.push_back(purchase);

            m_dateBasedHistory[foundIndex]->setPurchases(purchases);
            m_dateBasedHistory[foundIndex]->setDueAmount(m_dateBasedHistory[foundIndex]->getDueAmount() + purchase->getInstallmentValue());
        }
    }
}