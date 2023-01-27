# KolayC++
# **Work in progress**

## Strings in switches
Credit to [@hare1039's beautiful_switch.cpp](https://gist.github.com/hare1039/581b20cc8fbc8058d875894f05e655e5)
Kolay adds string support in switch statements. Cases have to be marked with an underscore after them `"like this"_`.

`sswitch(string)` and `switch(string_switch(string))` are identical.

```cpp
sswitch(string_here) {
	case "example"_:
		//do something
		break;
}
```