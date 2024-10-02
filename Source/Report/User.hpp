#pragma once

#include "Report.hpp"

namespace Financy
{
    class User;

    namespace Report
    {
        struct UserProps : Props
        {
            User* user = nullptr;
        };

        void generatreUserReport(const UserProps& inProps);
    }
}