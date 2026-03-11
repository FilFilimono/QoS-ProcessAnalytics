#include <iostream>
#include <iomanip>
#include <fstream>
#include <chrono>
#include <pthread.h>
#include <vector>
#include <cmath>

extern "C" {
    double compute_series_arm(double x, double eps);
    double compute_y_arm(double x); 
}

void set_perf(bool p_core) {
    if (p_core) {
        pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0);
    } else {
        pthread_set_qos_class_self_np(QOS_CLASS_BACKGROUND, 0);
    }
}


void print_detailed_table(double a, double b, double h, double eps, const std::string& label) {
    std::cout << "\nТаблица результатов для " << label << " (детальный расчет):\n";
    std::cout << std::string(85, '-') << "\n";
    std::cout << std::left << std::setw(8) << "x" 
              << std::setw(15) << "S(x)" 
              << std::setw(15) << "Y(x)" 
              << std::setw(15) << "Разность" << "\n";
    std::cout << std::string(85, '-') << "\n";

    for (double x = a; x <= b + h/2; x += h) {
        double s_val = compute_series_arm(x, eps);
        double y_val = exp(cos(x)) * cos(sin(x)); 
        double diff = std::abs(s_val - y_val);

        std::cout << std::fixed << std::setprecision(4) 
                  << std::left << std::setw(8) << x 
                  << std::setw(15) << s_val 
                  << std::setw(15) << y_val 
                  << std::setw(15) << diff << "\n";
    }
    std::cout << std::string(85, '-') << "\n";
}

int main() {
    double a, b, h, eps;
    std::cout << "Введите a, b, h, eps: ";
    std::cin >> a >> b >> h >> eps;

    std::ofstream csv("scaling.csv");
    csv << "i,time_e,time_p\n";

    std::vector<int> i_list = {1000, 2000, 3000, 4000, 5000};

    for (int i_val : i_list) {
        std::cout << "\n[Тест нагрузки i = " << i_val << "]" << std::endl;

        
        set_perf(false);
        auto s_e = std::chrono::high_resolution_clock::now();
        for (double x = a; x <= b + h/2; x += h) {
            for(int j = 0; j < i_val; ++j) compute_series_arm(x, eps);
        }
        auto e_e = std::chrono::high_resolution_clock::now();
        double t_e = std::chrono::duration<double, std::milli>(e_e - s_e).count();
        std::cout << "E-Core завершено за: " << t_e << " ms" << std::endl;

        
        set_perf(true);
        auto s_p = std::chrono::high_resolution_clock::now();
        for (double x = a; x <= b + h/2; x += h) {
            for(int j = 0; j < i_val; ++j) compute_series_arm(x, eps);
        }
        auto e_p = std::chrono::high_resolution_clock::now();
        double t_p = std::chrono::duration<double, std::milli>(e_p - s_p).count();
        std::cout << "P-Core завершено за: " << t_p << " ms" << std::endl;

        csv << i_val << "," << t_e << "," << t_p << "\n";

        
        if (i_val == 5000) {
            set_perf(false);
            print_detailed_table(a, b, h, eps, "E-CORE");
            set_perf(true);
            print_detailed_table(a, b, h, eps, "P-CORE");
        }
    }

    csv.close();
    return 0;
}