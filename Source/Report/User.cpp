#include "Report/User.hpp"

#include <filesystem>
#include <stdexcept>
#include <iostream>

#include "hpdf.h"

#include "Core/FileSystem.hpp"
#include "Core/Globals.hpp"
#include "UI/Account.hpp"
#include "UI/Purchase.hpp"
#include "UI/User.hpp"

constexpr std::uint32_t PAGE_VERTICAL_PADDING = 5;
constexpr std::uint32_t PAGE_HORIZONTAL_PADDING = 15;

constexpr std::uint32_t TITLE_FONT_SIZE = 14;
constexpr std::uint32_t FONT_SIZE = 8;

constexpr std::uint32_t ACCOUNT_HEADER_HEIGHT = 25;

constexpr std::uint32_t PURCHASE_HORIZONTAL_PADDING = 5;
constexpr std::uint32_t PURCHASE_HEIGHT = 20;
constexpr std::uint32_t PURCHASE_GAP = 10;

namespace Financy
{
    namespace Report
    {
        void generateAccountHeader(
            HPDF_Page &outPage,
            Account *inAccount,
            const HPDF_Font &inFont,
            const HPDF_Rect &inRect)
        {
            if (inAccount->getDueAmount() <= 0.0f)
            {
                return;
            }

            const std::uint32_t halvedFontSize = TITLE_FONT_SIZE * 0.5f;

            const std::string &name = inAccount->getName().toStdString();

            std::string totalValue = std::to_string(inAccount->getDueAmount(inAccount->getUserId()));
            totalValue = std::string(totalValue.begin(), totalValue.end() - 5);

            HPDF_Rect rect;
            rect.top = inRect.top;
            rect.bottom = inRect.top - ACCOUNT_HEADER_HEIGHT;
            rect.left = inRect.left + PAGE_HORIZONTAL_PADDING;
            rect.right = inRect.right;

            float red = 0.3f;
            float green = 0.3f;
            float blue = 0.3f;

            HPDF_Page_SetRGBStroke(outPage, red, green, blue);
            HPDF_Page_SetRGBFill(outPage, red, green, blue);

            float width = (rect.right - rect.left) + (PAGE_HORIZONTAL_PADDING * 2.0f);

            HPDF_Page_Rectangle(
                outPage,
                rect.left - PAGE_HORIZONTAL_PADDING,
                rect.top,
                width,
                1);
            HPDF_Page_ClosePathFillStroke(outPage);

            HPDF_Page_SetRGBFill(outPage, 0.0f, 0.0f, 0.0f);

            HPDF_Page_BeginText(outPage);
            HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
            HPDF_Page_TextOut(
                outPage,
                rect.left,
                rect.top + halvedFontSize,
                name.c_str());
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
            HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
            HPDF_Page_TextOut(
                outPage,
                rect.right - (totalValue.size() * halvedFontSize),
                rect.top + halvedFontSize,
                totalValue.c_str());
            HPDF_Page_EndText(outPage);
        }

        void generatePurchaseItem(
            HPDF_Page &outPage,
            Purchase *inPurchase,
            const QDate &inCurrentDate,
            std::uint32_t closingDay,
            const HPDF_Font &inFont,
            const HPDF_Rect &inRect,
            bool bContainsBackground)
        {
            const std::uint32_t horizontalPadding = PAGE_HORIZONTAL_PADDING + PURCHASE_HORIZONTAL_PADDING;
            const std::uint32_t halvedFontSize = FONT_SIZE * 0.5f;

            std::string date = inPurchase->getDate().toString("dd/MM/yy").toStdString();
            std::string establishment = inPurchase->getName().toStdString();
            establishment.append(" ");
            establishment.append(
                std::to_string(
                    inPurchase->getPaidInstallments(
                        inCurrentDate,
                        closingDay)));
            establishment.append("/");
            establishment.append(
                std::to_string(
                    inPurchase->getInstallments()));

            if (inPurchase->hasDescription())
            {
                establishment.append(" - ");
                establishment.append(inPurchase->getDescription().toStdString());
            }

            std::string value = std::to_string(inPurchase->getInstallmentValue());
            value = std::string(value.begin(), value.end() - 5);

            HPDF_Rect rect;
            rect.top = inRect.top;
            rect.bottom = inRect.top + PURCHASE_HEIGHT;
            rect.left = inRect.left;
            rect.right = inRect.right;

            if (bContainsBackground)
            {

                float red = 0.93f;
                float green = 0.93f;
                float blue = 0.93f;

                HPDF_Page_SetRGBStroke(outPage, red, green, blue);
                HPDF_Page_SetRGBFill(outPage, red, green, blue);

                float width = (rect.right - rect.left) + horizontalPadding;

                HPDF_Page_Rectangle(
                    outPage,
                    rect.left,
                    rect.top,
                    width,
                    PURCHASE_HEIGHT);
                HPDF_Page_ClosePathFillStroke(outPage);
            }

            HPDF_Page_SetRGBFill(outPage, 0.0f, 0.0f, 0.0f);

            HPDF_Page_BeginText(outPage);
            HPDF_Page_SetFontAndSize(outPage, inFont, FONT_SIZE);
            HPDF_Page_TextOut(
                outPage,
                horizontalPadding,
                rect.top + FONT_SIZE,
                date.c_str());
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
            HPDF_Page_SetFontAndSize(outPage, inFont, FONT_SIZE);
            HPDF_Page_TextOut(
                outPage,
                horizontalPadding + 50,
                rect.top + FONT_SIZE,
                establishment.c_str());
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
            HPDF_Page_SetFontAndSize(outPage, inFont, FONT_SIZE);
            HPDF_Page_TextOut(
                outPage,
                rect.right - (value.size() * halvedFontSize),
                rect.top + FONT_SIZE,
                value.c_str());
            HPDF_Page_EndText(outPage);
        }

        void generateTotalFooter(
            HPDF_Page &outPage,
            User *inUser,
            const HPDF_Font &inFont,
            const HPDF_Rect &inRect)
        {
            const std::uint32_t halvedFontSize = TITLE_FONT_SIZE * 0.5f;

            std::string totalValue = std::to_string(inUser->getDueAmount(inUser->getId()));
            totalValue = std::string(totalValue.begin(), totalValue.end() - 5);

            std::string total = totalValue;

            HPDF_Rect background;
            background.top = inRect.bottom + ((ACCOUNT_HEADER_HEIGHT * 2U) - PAGE_VERTICAL_PADDING);
            background.bottom = inRect.bottom;
            background.left = inRect.left + PAGE_HORIZONTAL_PADDING;
            background.right = inRect.right;

            float red = 0.3f;
            float green = 0.3f;
            float blue = 0.3f;

            HPDF_Page_SetRGBStroke(outPage, red, green, blue);
            HPDF_Page_SetRGBFill(outPage, red, green, blue);

            float width = (background.right - background.left) + (PAGE_HORIZONTAL_PADDING * 2U);

            HPDF_Page_Rectangle(
                outPage,
                background.left - PAGE_HORIZONTAL_PADDING,
                background.top,
                width,
                ACCOUNT_HEADER_HEIGHT);
            HPDF_Page_ClosePathFillStroke(outPage);

            HPDF_Page_SetRGBFill(outPage, 1.0f, 1.0f, 1.0f);

            HPDF_Page_BeginText(outPage);
            HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
            HPDF_Page_TextOut(
                outPage,
                background.left,
                background.top + halvedFontSize,
                "Total");
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
            HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
            HPDF_Page_TextOut(
                outPage,
                background.right - (total.size() * halvedFontSize),
                background.top + halvedFontSize,
                total.c_str());
            HPDF_Page_EndText(outPage);
        }

        void generateMonthlyReport(HPDF_Doc &outDocument, const HPDF_Font &inFont, User *inUser, const QDate &inDate)
        {
            HPDF_Page page = HPDF_AddPage(outDocument);
            HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT);

            HPDF_Rect defaultRect{
                PAGE_HORIZONTAL_PADDING,
                PAGE_VERTICAL_PADDING,
                HPDF_Page_GetWidth(page) - (PAGE_HORIZONTAL_PADDING * 2U),
                HPDF_Page_GetHeight(page) - (PAGE_VERTICAL_PADDING * 2U),
            };

            HPDF_Rect currentRect = defaultRect;

            QDate currentDate = inDate;

            for (Account *account : inUser->getAccounts(Account::Type::Expense))
            {
                if (account->getDueAmount() <= 0.0f)
                {
                    continue;
                }

                currentRect.top -= ACCOUNT_HEADER_HEIGHT;

                generateAccountHeader(
                    page,
                    account,
                    inFont,
                    currentRect);

                currentRect.top -= PURCHASE_GAP;

                std::uint32_t purchaseCount = 0;

                std::uint32_t closingDay = account->getClosingDay();

                for (Purchase *purchase : account->getPurchases(account->getUserId()))
                {
                    if (purchase->isFullyPaid(currentDate, closingDay))
                    {
                        continue;
                    }

                    currentRect.top -= PURCHASE_HEIGHT;

                    generatePurchaseItem(
                        page,
                        purchase,
                        currentDate,
                        closingDay,
                        inFont,
                        currentRect,
                        purchaseCount % 2 == 0);

                    if (currentRect.top - PURCHASE_HEIGHT <= defaultRect.bottom)
                    {

                        page = HPDF_AddPage(outDocument);
                        HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT);
                        currentRect = defaultRect;
                    }

                    purchaseCount++;
                }

                currentRect.top -= PURCHASE_GAP;

                if (currentRect.top - ((PURCHASE_HEIGHT + ACCOUNT_HEADER_HEIGHT) * 2U) + PURCHASE_GAP <= defaultRect.bottom)
                {
                    page = HPDF_AddPage(outDocument);
                    HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT);
                    currentRect = defaultRect;
                }
            }

            generateTotalFooter(
                page,
                inUser,
                inFont,
                currentRect);
        }

        void generateYearlyReport(HPDF_Doc &outDocument, const HPDF_Font &inFont, User *inUser)
        {

            for (std::uint32_t month = 1; month <= 12; month++)
            {
                QDate currentDate = QDate(Globals::getCurrentDate().year(), month, 1);
                currentDate = currentDate.addDays(currentDate.daysInMonth() - 1);

                HPDF_Page outPage = HPDF_AddPage(outDocument);
                HPDF_Page_SetSize(outPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT);

                QString title = "";
                title.append(std::to_string(currentDate.month()));
                title.append("/");
                title.append(std::to_string(currentDate.year()));

                HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, (TITLE_FONT_SIZE * 5));
                HPDF_Page_TextOut(
                    outPage,
                    PAGE_HORIZONTAL_PADDING,
                    PAGE_VERTICAL_PADDING + (TITLE_FONT_SIZE * 5), title.toStdString().c_str());
                HPDF_Page_EndText(outPage);

                generateMonthlyReport(outDocument, inFont, inUser, currentDate);
            }
        }

        void generatreUserReport(const UserProps &inProps)
        {
            if (!inProps.user)
            {
                return;
            }

            HPDF_Doc document = HPDF_New(
                [](
                    HPDF_STATUS inError,
                    HPDF_STATUS inDetail,
                    void *inData)
                {
                    std::cout << "[error_no]" << inError << "\n";
                },
                nullptr);

            if (!document)
            {
                throw std::runtime_error("Cannot create PDF document object");
            }

            HPDF_UseUTFEncodings(document);

            HPDF_Font font = HPDF_GetFont(
                document,
                HPDF_LoadTTFontFromFile(document, "Assets/Fonts/Inter.ttf", HPDF_TRUE),
                "UTF-8");

            switch (inProps.type)
            {
            case Type::Monthly:
                generateMonthlyReport(document, font, inProps.user, Globals::getCurrentDate());

                break;

            case Type::Yearly:
                generateYearlyReport(document, font, inProps.user);

            default:
                break;
            }

            if (!inProps.path.empty())
            {
                std::filesystem::create_directories(inProps.path);
            }

            std::string filepath = inProps.path + (inProps.path.empty() ? "" : "/") + inProps.name + ".pdf";

            HPDF_SaveToFile(document, filepath.c_str());

            HPDF_Free(document);

            FileSystem::openFile(filepath);
        }
    }
}