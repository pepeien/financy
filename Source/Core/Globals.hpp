#pragma once

#include <QtCore>

namespace Financy
{
    namespace Globals
    {
        const QDate& getCurrentDate();
        void setCurrentDate(const QDate& inDate);
    }
}