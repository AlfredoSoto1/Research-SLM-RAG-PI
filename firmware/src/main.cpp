#include <iostream>
#include <string_view>

#ifndef SLM_RAG_PI_FIRMWARE_VERSION
#define SLM_RAG_PI_FIRMWARE_VERSION "dev"
#endif

namespace {

void PrintUsage(const char* program_name) {
  std::cout << "Usage: " << program_name << " [--help | --version]\n"
            << "Start the SLM RAG Pi firmware runtime.\n";
}

}  // namespace

int main(int argc, char* argv[]) {
  if (argc > 1) {
    const std::string_view argument(argv[1]);
    if (argument == "--help" || argument == "-h") {
      PrintUsage(argv[0]);
      return 0;
    }
    if (argument == "--version" || argument == "-v") {
      std::cout << "slm-rag-pi-firmware " << SLM_RAG_PI_FIRMWARE_VERSION << '\n';
      return 0;
    }

    std::cerr << "Unknown option: " << argument << '\n';
    PrintUsage(argv[0]);
    return 2;
  }

  std::cout << "SLM RAG Pi firmware runtime ready (version "
            << SLM_RAG_PI_FIRMWARE_VERSION << ").\n";
  return 0;
}
