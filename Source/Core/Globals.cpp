#include "Core/Globals.hpp"

QDate m_currentDate = QDate::currentDate();

namespace Financy
{
    const QDate& Globals::getCurrentDate()
    {
        return m_currentDate;
    }

    void Globals::setCurrentDate(const QDate& inDate)
    {
        m_currentDate = inDate;
    }
}