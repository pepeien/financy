#include "Main.hpp"

#include <iostream>

#include "QtWidgets"
#include "QtQuick"
#include "QtCore"
#include "QtQml"

#include "rapidjson/document.h"

#include "Core/FileSystem.hpp"

#include "UI/ColorSchene.hpp"
#include "UI/User.hpp"

void setColorScheme(Financy::ETheme inTheme, Financy::ColorScheme* outColorScheme)
{
    switch (inTheme)
    {
    case Financy::ETheme::DARK:
        outColorScheme->setBackgroundColor("#E1F7F5");
        outColorScheme->setForegroundColor("#D9D9D9");
        outColorScheme->setLightColor("#596B5D");
        outColorScheme->setDarkColor("#39473C");

        return;

    case Financy::ETheme::LIGHT:
    default:
        outColorScheme->setBackgroundColor("#E1F7F5");
        outColorScheme->setForegroundColor("#D9D9D9");
        outColorScheme->setLightColor("#596B5D");
        outColorScheme->setDarkColor("#39473C");

        return;
    }
}

void setupUsers(QList<Financy::User*>& outUserList)
{
    std::string usersFileLocation = "Users.json";

    if (!Financy::FileSystem::doesFileExist(usersFileLocation))
    {
        return;
    }

    std::vector<char> userRaw = Financy::FileSystem::readFile(usersFileLocation);

    rapidjson::Document userDoc;
    userDoc.Parse(
        std::string(userRaw.begin(), userRaw.end()).c_str()
    );

    if (userDoc.Empty())
    {
        return;
    }

    for (rapidjson::Value::ConstValueIterator itr = userDoc.Begin(); itr != userDoc.End(); ++itr) {
        Financy::User* user = new Financy::User();
        user->setFirstName(itr->GetObject()["firstName"].GetString());
        user->setLastName(  itr->GetObject()["lastName"].GetString());
        user->setPicture(    itr->GetObject()["picture"].GetString());

        outUserList.push_back(user);
    }
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    std::unique_ptr<Financy::ColorScheme> colorScheme = std::make_unique<Financy::ColorScheme>();
    setColorScheme(Financy::ETheme::LIGHT, colorScheme.get());

    QList<Financy::User*> users;
    setupUsers(users);

    QQuickView viewer;
    viewer.setTitle(QStringLiteral("Financy"));
    viewer.setMinimumWidth(1600);
    viewer.setMinimumHeight(900);
    viewer.rootContext()->setContextProperty("colorScheme", colorScheme.get());
    viewer.rootContext()->setContextProperty("users", QVariant::fromValue(users));
    viewer.setSource(QUrl("qrc:/Pages/Login.qml"));
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);

    QObject::connect(
        viewer.engine(),
        &QQmlEngine::quit,
        &viewer,
        &QWindow::close
    );

    viewer.show();

    return app.exec();
}