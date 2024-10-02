#include "Report/User.hpp"

#include <filesystem>
#include <stdexcept>
#include <iostream>

#include "hpdf.h"

#include "Core/Globals.hpp"
#include "UI/Account.hpp"
#include "UI/Purchase.hpp"
#include "UI/User.hpp"

constexpr std::uint32_t PAGE_VERTICAL_PADDING       = 0;
constexpr std::uint32_t PAGE_HORIZONTAL_PADDING     = 5;

constexpr std::uint32_t TITLE_FONT_SIZE             = 14;
constexpr std::uint32_t FONT_SIZE                   = 8;

constexpr std::uint32_t ACCOUNT_HEADER_HEIGHT       = 25;

constexpr std::uint32_t PURCHASE_HORIZONTAL_PADDING = 5;
constexpr std::uint32_t PURCHASE_HEIGHT             = 20;
constexpr std::uint32_t PURCHASE_GAP                = 10;

namespace Financy
{
    namespace Report
    {
        void generateAccountHeader(
            HPDF_Page& outPage,
            Account* inAccount,
            const HPDF_Font& inFont,
            const HPDF_Rect& inRect
        )
        {
            if (inAccount->getDueAmount() <= 0.0f)
            {
                return;
            }

            const std::uint32_t halvedFontSize = TITLE_FONT_SIZE * 0.5f;

            const std::string& name = inAccount->getName().toStdString();

            std::string totalValue = std::to_string(inAccount->getDueAmount());
            totalValue             = std::string(totalValue.begin(), totalValue.end() - 5);

            HPDF_Rect rect;
            rect.top    = inRect.top;
            rect.bottom = inRect.top - ACCOUNT_HEADER_HEIGHT;
            rect.left   = inRect.left;
            rect.right  = inRect.right;

            float red   = 0.3f;
            float green = 0.3f;
            float blue  = 0.3f;

            HPDF_Page_SetRGBStroke(outPage, red, green, blue);
            HPDF_Page_SetRGBFill(outPage, red, green, blue);
                HPDF_Page_Rectangle(
                    outPage,
                    rect.left - PAGE_HORIZONTAL_PADDING,
                    rect.top,
                    rect.right + PAGE_HORIZONTAL_PADDING,
                    1
                );
            HPDF_Page_ClosePathFillStroke(outPage);

            HPDF_Page_SetRGBFill(outPage, 0.0f, 0.0f, 0.0f);

            HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
                HPDF_Page_TextOut(
                    outPage,
                    rect.left,
                    rect.top + halvedFontSize,
                    name.c_str()
                );
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
                HPDF_Page_TextOut(
                    outPage,
                    rect.right - (totalValue.size() * halvedFontSize),
                    rect.top + halvedFontSize,
                    totalValue.c_str()
                );
            HPDF_Page_EndText(outPage);
        }

        void generatePurchaseItem(
            HPDF_Page& outPage,
            Purchase* inPurchase,
            const QDate& inCurrentDate,
            std::uint32_t closingDay,
            const HPDF_Font& inFont,
            const HPDF_Rect& inRect,
            bool bContainsBackground
        )
        {
            const std::uint32_t horizontalPadding = PAGE_HORIZONTAL_PADDING + PURCHASE_HORIZONTAL_PADDING;
            const std::uint32_t halvedFontSize    = FONT_SIZE * 0.5f;

            std::string date          = inPurchase->getDate().toString("dd/MM/yy").toStdString();
            std::string establishment = inPurchase->getName().toStdString();
            establishment.append(" ");
            establishment.append(
                std::to_string(
                    inPurchase->getPaidInstallments(
                        inCurrentDate,
                        closingDay
                    )
                )
            );
            establishment.append("/");
            establishment.append(
                std::to_string(
                    inPurchase->getInstallments()
                )
            );
            std::string value         = std::to_string(inPurchase->getInstallmentValue());
            value                     = std::string(value.begin(), value.end() - 5);

            HPDF_Rect rect;
            rect.top    = inRect.top;
            rect.bottom = inRect.top + PURCHASE_HEIGHT;
            rect.left   = inRect.left;
            rect.right  = inRect.right;

            if (bContainsBackground)
            {

                float red   = 0.93f;
                float green = 0.93f;
                float blue  = 0.93f;

                HPDF_Page_SetRGBStroke(outPage, red, green, blue);
                HPDF_Page_SetRGBFill(outPage, red, green, blue);
                    HPDF_Page_Rectangle(
                        outPage,
                        rect.left - horizontalPadding,
                        rect.top,
                        rect.right + horizontalPadding,
                        PURCHASE_HEIGHT
                    );
                HPDF_Page_ClosePathFillStroke(outPage);
            }

            HPDF_Page_SetRGBFill(outPage, 0.0f, 0.0f, 0.0f);

            HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, FONT_SIZE);
                HPDF_Page_TextOut(
                    outPage,
                    horizontalPadding,
                    rect.top + FONT_SIZE,
                    date.c_str()
                );
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, FONT_SIZE);
                HPDF_Page_TextOut(
                    outPage,
                    horizontalPadding + 50,
                    rect.top + FONT_SIZE,
                    establishment.c_str()
                );
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, FONT_SIZE);
                HPDF_Page_TextOut(
                    outPage,
                    rect.right - (value.size() * halvedFontSize),
                    rect.top + FONT_SIZE,
                    value.c_str()
                );
            HPDF_Page_EndText(outPage);
        }

        void generateTotalFooter(
            HPDF_Page& outPage,
            User* inUser,
            const HPDF_Font& inFont,
            const HPDF_Rect& inRect
        )
        {
            const std::uint32_t halvedFontSize = TITLE_FONT_SIZE * 0.5f;

            std::string totalValue = std::to_string(inUser->getDueAmount());
            totalValue             = std::string(totalValue.begin(), totalValue.end() - 5);

            std::string total = totalValue;

            HPDF_Rect background;
            background.top    = inRect.bottom;
            background.bottom = inRect.bottom - ACCOUNT_HEADER_HEIGHT;
            background.left   = inRect.left;
            background.right  = inRect.right;

            float red   = 0.3f;
            float green = 0.3f;
            float blue  = 0.3f;

            HPDF_Page_SetRGBStroke(outPage, red, green, blue);
            HPDF_Page_SetRGBFill(outPage, red, green, blue);
                HPDF_Page_Rectangle(
                    outPage,
                    background.left - PAGE_HORIZONTAL_PADDING,
                    background.top,
                    background.right + PAGE_HORIZONTAL_PADDING,
                    ACCOUNT_HEADER_HEIGHT
                );
            HPDF_Page_ClosePathFillStroke(outPage);

            HPDF_Page_SetRGBFill(outPage, 1.0f, 1.0f, 1.0f);

            HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
                HPDF_Page_TextOut(
                    outPage,
                    background.left,
                    background.top + halvedFontSize,
                    "Total"
                );
            HPDF_Page_EndText(outPage);

            HPDF_Page_BeginText(outPage);
                HPDF_Page_SetFontAndSize(outPage, inFont, TITLE_FONT_SIZE);
                HPDF_Page_TextOut(
                    outPage,
                    background.right - (total.size() * halvedFontSize),
                    background.top + halvedFontSize,
                    total.c_str()
                );
            HPDF_Page_EndText(outPage);
        }

        void generatreUserReport(const UserProps& inProps)
        {
            if (!inProps.user)
            {
                return;
            }

            HPDF_Doc document = HPDF_New(
                [](
                    HPDF_STATUS inError,
                    HPDF_STATUS inDetail,
                    void* inData
                )
                {
                    std::cout << "[error_no]" << inError  << "\n";
                },
                nullptr
            );
    
            if (!document) {
                throw std::runtime_error("Cannot create PDF document object");
            }

            HPDF_UseUTFEncodings(document);

            HPDF_Font font = HPDF_GetFont(
                document,
                HPDF_LoadTTFontFromFile(document, "Assets/Fonts/Inter.ttf", HPDF_TRUE),
                "UTF-8"
            );

            HPDF_Page page = HPDF_AddPage(document);
            HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT);

            const HPDF_Rect defaultRect {
                PAGE_HORIZONTAL_PADDING,
                PAGE_VERTICAL_PADDING,
                HPDF_Page_GetWidth(page) - PAGE_HORIZONTAL_PADDING,
                HPDF_Page_GetHeight(page) - PAGE_VERTICAL_PADDING,
            };

            HPDF_Rect currentRect = defaultRect;

            QDate currentDate = Globals::getCurrentDate();

            for (Account* account : inProps.user->getAccounts(Account::Type::Expense))
            {
                if (account->getDueAmount() <= 0.0f)
                {
                    continue;
                }

                currentRect.top -= ACCOUNT_HEADER_HEIGHT;

                generateAccountHeader(
                    page,
                    account,
                    font,
                    currentRect
                );

                currentRect.top -= PURCHASE_GAP;

                std::uint32_t purchaseCount = 0;

                std::uint32_t closingDay = account->getClosingDay();

                for (Purchase* purchase : account->getPurchases())
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
                        font,
                        currentRect,
                        purchaseCount % 2 == 0
                    );

                    if (currentRect.top <= (PURCHASE_GAP + PURCHASE_HEIGHT))
                    {
                        currentRect.top = defaultRect.top;

                        page = HPDF_AddPage(document);
                    }

                    purchaseCount++;
                }

                currentRect.top -= PURCHASE_GAP;

                if (currentRect.top <= (PURCHASE_GAP + PURCHASE_HEIGHT))
                {
                    currentRect.top = defaultRect.top;

                    page = HPDF_AddPage(document);
                }
            }

            generateTotalFooter(
                page,
                inProps.user,
                font,
                currentRect
            );

            if (!inProps.path.empty())
            {
                std::filesystem::create_directories(inProps.path);
            }

            std::string filepath = inProps.path + (inProps.path.empty() ? "" :  "/") + inProps.name + ".pdf";

            HPDF_SaveToFile(document, filepath.c_str());

            HPDF_Free(document);
        }
    }
}