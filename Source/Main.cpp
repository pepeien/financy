#include "Main.hpp"

#include "Core/Application.hpp"

int main(int argc, char *argv[])
{
    std::unique_ptr<Financy::Application> app = std::make_unique<Financy::Application>(
        "Financy"
    );

    return app->run(argc, argv);
}