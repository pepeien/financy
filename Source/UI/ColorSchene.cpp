#include "ColorSchene.hpp"

namespace Financy
{
    ColorScheme::ColorScheme()
        : m_background("#FFFFFF"),
        m_foreground("#000000"),
        m_light("#FFFFFF"),
        m_dark("#000000")
    {}

    void ColorScheme::setBackgroundColor(const QColor& inColor)
    {
        m_background = inColor;

        emit colorsChanged();
    }

    void ColorScheme::setForegroundColor(const QColor& inColor)
    {
        m_foreground = inColor;

        emit colorsChanged();
    }

    void ColorScheme::setLightColor(const QColor& inColor)
    {
        m_light = inColor;

        emit colorsChanged();
    }

    void ColorScheme::setDarkColor(const QColor& inColor)
    {
        m_dark = inColor;

        emit colorsChanged();
    }
}