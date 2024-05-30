#pragma once

#include <QtCore>
#include <QMetaType>

#include "Colors.hpp"
#include "User.hpp"

namespace Financy
{
    constexpr auto USER_FILE_NAME     = "Users.json";
    constexpr auto SETTINGS_FILE_NAME = "Settings.json";

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

    signals:
        void onThemeUpdate();
        void onShowcaseThemeUpdate();

        void onSelectUserUpdate();
        void onUsersUpdate();

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

        // Theme
        void updateTheme(Colors::Theme inTheme);
        void updateShowcaseTheme(Colors::Theme inTheme);

        // Utils
        QDate addMonths(const QDate& inDate, int inMonths);

        QString getLongDate(const QDate& inDate);
        QString getLongMonth(const QDate& inDate);

        float getDueAmount(const QList<Purchase*>& inPurchases);

        QList<QString> getPurchaseTypes();
        QString getPurchaseTypeName(Purchase::Type inType);

    private:
        // User
        void loadUsers();
        void writeUser(User* inUser);
        User* getUser(std::uint32_t inId);
        void deleteUserFromFile(std::uint32_t inId);
        void deleteUserFromMemory(std::uint32_t inId);

        // Settings
        void loadSettings();
        void writeSettings();

        // Theme
        void reloadTheme();
        void reloadShowcaseTheme();

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
    };
}