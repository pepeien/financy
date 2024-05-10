#pragma once

#include <QtCore>
#include <QMetaType>

#include "Colors.hpp"
#include "User.hpp"

namespace Financy
{
    class Internals : public QObject
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

    public:
        Internals(QObject* parent = nullptr);
        ~Internals();

    public slots:
        // Utils
        QString openFileDialog(
            const QString& inTitle,
            const QString& inExtensions
        );
        QList<QColor> getUserColorsFromImage(const QString& inImage);

        // Modifiers
        User* addUser( 
            const QString& inFirstName,
            const QString& inLastName,
            const QUrl& inPicture,
            const QColor& inPrimaryColor,
            const QColor& inSecondaryColor
        );
        void login(User* inUser);
        void logout();

        // Theme
        void updateTheme(Colors::Theme inTheme);
        void updateShowcaseTheme(Colors::Theme inTheme);
    
    signals:
        void onThemeUpdate();
        void onShowcaseThemeUpdate();

        void onSelectUserUpdate();
        void onUsersUpdate();

    private:
        void setupUsers();
        void writeUser(User* inUser);

    private:
        // consts
        std::string USER_FILE_NAME = "Users.json";

        // Colors
        Colors::Theme m_colorsTheme;
        Colors* m_colors;

        Colors::Theme m_showcaseColorsTheme;
        Colors* m_showcaseColors;

        // Data
        User* m_selectedUser;
        QList<User*> m_users;
    };
}