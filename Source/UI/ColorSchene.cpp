#include "ColorSchene.hpp"

namespace Financy
{
    ColorScheme::ColorScheme()
        : m_theme(ETheme::LIGHT)
    {
        onThemeChange();
    }

    void ColorScheme::setTheme(ETheme theme)
    {
        if (m_theme == theme)
        {
            return;
        }

        m_theme = theme;

        onThemeChange();

        emit themeChanged();
    }

    void ColorScheme::onThemeChange()
    {
        switch (m_theme)
        {
        case ETheme::DARK:
            m_background = "#E1F7F5";
            m_foreground = "#D9D9D9";
            m_light = "#596B5D";
            m_dark = "#39473C";

            return;

        case ETheme::LIGHT:
        default:
            m_background = "#E1F7F5";
            m_foreground = "#D9D9D9";
            m_light = "#596B5D";
            m_dark = "#39473C";

            return;
        }
    }
}