#include <cpp_kolay.hpp>

void foo() {
	unimplemented_exit();
}

i32 main(i32 argc, char const* argv[])
{
	std::string input;
	std::cin >> input;

	sswitch (input)
	{
	case "yes"_:
		std::cout << "\"yes\"\n";
		break;
	case "no"_:
		std::cout << "\"no\"\n";
		break;
	case "123"_:
		foo();
		break;
	default:
		break;
	}

	return 0;
}