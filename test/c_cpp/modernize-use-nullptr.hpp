#ifndef MODERNIZE_USE_NULLPTR_HPP
#define MODERNIZE_USE_NULLPTR_HPP

#include <cstddef>

namespace tidy {

  inline void bar(int*& p) {
    p = nullptr;
  }

  struct T {
    int* p_ = nullptr;

    void foo(int* p = nullptr) {
      bar(p);
    }
  };

}  // namespace tidy

#endif
