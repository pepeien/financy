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

        Q_PROPERTY(
            Colors* colors
            MEMBER m_colors
            NOTIFY onThemeUpdate
        )
        Q_PROPERTY(
            Colors* showcaseColors
            MEMBER m_showcaseColors
            NOTIFY onShowcaseThemeUpdate
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

        // Theme
        void updateTheme(Colors::Theme inTheme);
        void updateShowcaseTheme(Colors::Theme inTheme);
    
    signals:
        void onThemeUpdate();
        void onShowcaseThemeUpdate();

        void onUsersUpdate();

    private:
        void setupUsers();
        void writeUser(User* inUser);

    private:
        // consts
        std::string USER_FILE_NAME = "Users.json";

        // Colors
        Colors* m_colors;
        Colors* m_showcaseColors;

        // Data
        User* m_selectedUser;
        QList<User*> m_users;
    };
}