#pragma once

namespace Financy
{
    constexpr auto DATA_FOLDER_NAME   = "Data";
    constexpr auto ACCOUNT_FILE_NAME  = "Data/Accounts.json";
    constexpr auto PURCHASE_FILE_NAME = "Data/Purchases.json";
    constexpr auto SETTINGS_FILE_NAME = "Data/Settings.json";
    constexpr auto USER_FILE_NAME     = "Data/Users.json";

    constexpr std::uint32_t MIN_STATEMENT_CLOSING_DAY = 1;
    constexpr std::uint32_t MAX_STATEMENT_CLOSING_DAY = 30;

    constexpr std::uint32_t MIN_INSTALLMENT_COUNT = 1;
    constexpr std::uint32_t MAX_INSTALLMENT_COUNT = 120;

    constexpr auto FILES = { ACCOUNT_FILE_NAME, PURCHASE_FILE_NAME, USER_FILE_NAME, SETTINGS_FILE_NAME };
}
