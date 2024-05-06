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

    public slots:
        // Utils
        QString openFileDialog(
            const QString& inTitle,
            const QString& inExtensions
        );

        // Modifiers
        void updateTheme(Colors::Theme inTheme);
        void addUser( 
            const QString& inFirstName,
            const QString& inLastName,
            const QUrl& inPicture
        );

    private:
        // Colors
        std::unique_ptr<Colors> m_colors;

        // Data
        QList<User*> m_users;
    };
}