#pragma once

namespace Financy
{
    constexpr auto ACCOUNT_FILE_NAME  = "Accounts.json";
    constexpr auto PURCHASE_FILE_NAME = "Purchases.json";
    constexpr auto SETTINGS_FILE_NAME = "Settings.json";
    constexpr auto USER_FILE_NAME     = "Users.json";

    constexpr std::uint32_t MIN_STATEMENT_CLOSING_DAY = 1;
    constexpr std::uint32_t MAX_STATEMENT_CLOSING_DAY = 30;

    constexpr std::uint32_t MIN_INSTALLMENT_COUNT = 1;
    constexpr std::uint32_t MAX_INSTALLMENT_COUNT = 120;

    constexpr auto FILE_NAMES = { ACCOUNT_FILE_NAME, PURCHASE_FILE_NAME, USER_FILE_NAME, SETTINGS_FILE_NAME };
}
