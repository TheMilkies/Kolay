#ifndef KOLAY_TEST
#define KOLAY_TEST

#define BEGIN_TEST 
#define __TEST_COUT std::cout << "[TEST " __FILE__ ":" << __LINE__ << " " << __FUNCTION__ << "()]: " DEBCRESET 

#define TEST_EQ(a, b) if(a != b) 

#endif //KOLAY_TEST
