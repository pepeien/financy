#pragma once

namespace Financy
{
    constexpr auto USER_FILE_NAME     = "Users.json";
    constexpr auto SETTINGS_FILE_NAME = "Settings.json";
    constexpr auto PURCHASE_FILE_NAME = "Purchases.json";
    constexpr auto ACCOUNT_FILE_NAME  = "Accounts.json";

    constexpr std::uint32_t MIN_STATEMENT_CLOSING_DAY = 1;
    constexpr std::uint32_t MAX_STATEMENT_CLOSING_DAY = 30;
}
