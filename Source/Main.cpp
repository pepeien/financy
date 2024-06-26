#include "Main.hpp"

#include <iostream>

#include <QDebug>

#include "Core/Application.hpp"

int main(int argc, char *argv[])
{
    try
    {
        std::unique_ptr<Financy::Application> app = std::make_unique<Financy::Application>(
            "Financy"
        );

        app->run(argc, argv);
    }
    catch(const std::exception& e)
    {
        qDebug() << e.what();

        return 1;
    }

    return 0;
}