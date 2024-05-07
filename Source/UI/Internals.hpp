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

        // Modifiers
        void updateTheme(Colors::Theme inTheme);
        User* addUser( 
            const QString& inFirstName,
            const QString& inLastName,
            const QUrl& inPicture
        );
    
    signals:
        void onThemeUpdate();
        void onUsersUpdate();

    private:
        void setupUsers();
        void writeUser(User* inUser);

    private:
        // consts
        std::string USER_FILE_NAME = "Users.json";

        // Colors
        Colors* m_colors;

        // Data
        User* m_selectedUser;
        QList<User*> m_users;
    };
}