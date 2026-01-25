#pragma once

#include <string>

namespace Financy
{
    namespace Report
    {
        enum class Type
        {
            Monthly = 0,
            Yearly = 1
        };

        struct Props
        {
            std::string path = "";
            std::string name = "";
            Type type = Type::Monthly;
        };
    }
}