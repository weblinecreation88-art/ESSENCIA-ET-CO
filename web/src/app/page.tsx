import { Cta } from "@/components/landing/Cta";
import { Features } from "@/components/landing/Features";
import { Footer } from "@/components/landing/Footer";
import { Header } from "@/components/landing/Header";
import { Hero } from "@/components/landing/Hero";
import { ProductPreview } from "@/components/landing/ProductPreview";
import { Roles } from "@/components/landing/Roles";
import { StaffRecognition } from "@/components/landing/StaffRecognition";
import { WhyEssencia } from "@/components/landing/WhyEssencia";

export default function Home() {
  return (
    <>
      <Header />
      <main className="flex-1">
        <Hero />
        <Roles />
        <ProductPreview />
        <WhyEssencia />
        <Features />
        <StaffRecognition />
        <Cta />
      </main>
      <Footer />
    </>
  );
}
