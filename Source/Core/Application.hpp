#pragma once

#include <QtCore>
#include <QtWidgets>
#include <QtQuick>
#include <QtQml>

#include <rapidjson/document.h>

#include "UI/ColorScheme.hpp"
#include "UI/User.hpp"

namespace Financy
{
    class Application
    {
    public:
        Application();
        Application(const std::string& inTitle);
        Application(const std::string& inTitle, ETheme inTheme);
        ~Application();

    public:
        void updateTheme(ETheme inTheme);

        int run(int argc, char *argv[]);

    private:
        void setupUsers();

    private:
        // Window
        std::string m_title;

        // Theme
        std::unique_ptr<ColorScheme> m_colors;

        // Data
        QList<User*> m_users;
    };
}