using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Wizka
//Na podstawie PR ćw 3 z labów z robotyki

{
    /// <summary>
    /// Opis kinematyki robota
    /// </summary>
    class Robot
    {
        /// <summary>
        /// rozstaw kół
        /// </summary>
        public decimal d;

        /// <summary>
        /// promień koła
        /// </summary>
        public decimal r;

        /// <summary>
        /// prędkość kątowa koła lewego
        /// </summary>
        public double wl;

        /// <summary>
        /// prędkość kątowa koła prawego
        /// </summary>
        public double wp;

        //wektor położeń robota
        public double x;
        public double y;
        public double phi;

        /// <summary>
        /// okres próbkowania
        /// </summary>
        public double Tp;

        /// <summary>
        /// Prędkość liniowa robota
        /// </summary>
        /// <returns></returns>
        public double Velocity()
        {
            double vel = new double();

            vel = (Math.Abs(wp + wl) * (double)r) / 2;

            return vel;
        }

        /// <summary>
        /// prędkość kątowa robota
        /// </summary>
        /// <returns></returns>
        public double Omega()
        {
            double omg = new double();

            omg = (Math.Abs(wp - wl) * (double)r) / (double)d;

            return omg;
        }

        /// <summary>
        /// prędkość liniowa robota wzdłuż osi X
        /// </summary>
        /// <returns></returns>
        public double Vxn()
        {
            double vx = new double();

            vx = ((Math.Abs(wp + wl) * (double)r) / 2) * Math.Cos(phi);

            return vx;
        }

        /// <summary>
        /// prędkość liniowa robota wzdłuż osi Y
        /// </summary>
        /// <returns></returns>
        public double Vyn()
        {
            double vy = new double();

            vy = ((Math.Abs(wp + wl) * (double)r) / 2) * Math.Sin(phi);

            return vy;
        }

        /// <summary>
        /// oblicza pozycję robota w osi X
        /// </summary>
        public void Xn()
        {
            double xn = new double();

            xn = x + (double)Tp * Vxn();

            x = xn;
        }

        /// <summary>
        /// oblicza pozycję robota w osi Y
        /// </summary>
        public void Yn()
        {
            double yn = new double();

            yn = y + (double)Tp * Vyn();

            y = yn;
        }

        /// <summary>
        /// oblicza kąt obrotu robota
        /// </summary>
        public void Phin()
        {
            double phin = new double();

            phin = phi + (double)Tp * Omega();

            phi = phin;
        }

        /// <summary>
        /// Oblicza próbkę ruchu robota
        /// </summary>
        /// <param name="wl">prędkosć kątowa koła lewego</param>
        /// <param name="wp">prędkosć kątowa koła prawego</param>
        public void Step(double wl, double wp)
        {
            this.wl = wl;
            this.wp = wp;

            Xn();
            Yn();
            Phin();

            //przekazanie tego do wektora i potem dopisywanie kolejnych wyrazów tego wektora do listy i tworzenie wykresów
            //albo pobieranie przez referencje pojedynczych wartości i rysowanie wykresu realtime

        }

        /// <summary>
        /// Konstruktor robota inicjujący wartości
        /// </summary>
        public Robot()
        {
            //początkowe wartości położenia robota
            x = 0.0;
            y = 0.0;
            phi = 0.0;

            d = (decimal)0.1;
            r = (decimal)0.05;
        }


    }
}
