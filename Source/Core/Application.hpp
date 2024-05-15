#pragma once

#include <QtCore>
#include <QtWidgets>
#include <QtQuick>
#include <QtQml>

#include "UI/Colors.hpp"
#include "UI/User.hpp"

namespace Financy
{
    class Application
    {
    public:
        Application();
        Application(const std::string& inTitle);
        Application(const std::string& inTitle, Colors::Theme inTheme);
        ~Application() = default;

    public:
        int run(int argc, char *argv[]);

    private:
        // Window
        std::string m_title;

        // Theme
        Colors::Theme m_theme;
    };
}