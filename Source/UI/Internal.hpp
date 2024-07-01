#pragma once

#include <QtCore>
#include <QMetaType>

#include "Colors.hpp"
#include "User.hpp"

namespace Financy
{
    class Internal : public QObject
    {
        Q_OBJECT

        // Theme
        Q_PROPERTY(
            Colors::Theme colorsTheme
            MEMBER m_colorsTheme
            NOTIFY onThemeUpdate
        )
        Q_PROPERTY(
            Colors* colors
            MEMBER m_colors
            NOTIFY onThemeUpdate
        )
        Q_PROPERTY(
            Colors::Theme showcaseColorsTheme
            MEMBER m_showcaseColorsTheme
            NOTIFY onShowcaseThemeUpdate
        )
        Q_PROPERTY(
            Colors* showcaseColors
            MEMBER m_showcaseColors
            NOTIFY onShowcaseThemeUpdate
        )

        // User
        Q_PROPERTY(
            User* selectedUser
            MEMBER m_selectedUser
            NOTIFY onSelectUserUpdate
        )
        Q_PROPERTY(
            QList<User*> users
            MEMBER m_users
            NOTIFY onUsersUpdate
        )

        // Account
        Q_PROPERTY(
            QList<Account*> accounts
            MEMBER m_accounts
            NOTIFY onAccountsUpdate
        )

    signals:
        void onThemeUpdate();
        void onShowcaseThemeUpdate();

        void onSelectUserUpdate();
        void onUsersUpdate();

        void onAccountsUpdate();

    public:
        static void setSelectedUser(User* inUser);
        static User* getSelectedUser();

    public:
        Internal(QObject* parent = nullptr);
        ~Internal();

    public slots:
        // Utils
        QString openFileDialog(
            const QString& inTitle,
            const QString& inExtensions
        );
        QList<QColor> getUserColorsFromImage(const QString& inImage);

        // User
        User* getUser(std::uint32_t inId);
        QList<User*> getUsers(const QList<int>& inIds);
        User* createUser(
            const QString& inFirstName,
            const QString& inLastName,
            const QUrl& inPicture,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );
        void editUser(
            std::uint32_t inId,
            const QString& inFirstName,
            const QString& inLastName,
            const QUrl& inPicture,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );
        void deleteUser(std::uint32_t inId);

        void login(User* inUser);
        void logout();

        // Account
        void createAccount(
            const QString& inName,
            const QString& inClosingDay,
            const QString& inLimit,
            const QString& inType,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );
        void editAccount(
            std::uint32_t inId,
            const QString& inName,
            const QString& inClosingDay,
            const QString& inLimit,
            const QString& inType,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );
        void deleteAccount(std::uint32_t inId);

        // Theme
        void updateTheme(Colors::Theme inTheme);
        void updateShowcaseTheme(Colors::Theme inTheme);

        // Utils
        QDate addMonths(const QDate& inDate, int inMonths);

        bool isSameDate(const QDate& inDateA, const QDate& inDateB);
        QString getLongDate(const QDate& inDate);
        QString getLongMonth(const QDate& inDate);

        float getDueAmount(const QList<Purchase*>& inPurchases);

        QList<QString> getAccountTypes();
        QString getAccountTypeName(Account::Type inType);

        QList<QString> getPurchaseTypes();
        QString getPurchaseTypeName(Purchase::Type inType);

        std::uint32_t getMinStatementClosingDay();
        std::uint32_t getMaxStatementClosingDay();

        std::uint32_t getMinInstallmentCount();
        std::uint32_t getMaxInstallmentCount();

        void clear(QList<void*> inList, bool willDelete = false);

    private:
        // User
        void loadUsers();

        // Account
        void loadAccounts();
        Account* getAccount(std::uint32_t inId);

        // Settings
        void loadSettings();
        void writeSettings();

        // Theme
        void reloadTheme();
        void reloadShowcaseTheme();

        // Utils
        void normalizePurchases();

    private:
        // Settings
        Colors::Theme m_colorsTheme;

        // Theme
        Colors* m_colors;

        Colors::Theme m_showcaseColorsTheme;
        Colors* m_showcaseColors;

        // User
        User* m_selectedUser;
        QList<User*> m_users;

        // Account
        QList<Account*> m_accounts;
    };
}