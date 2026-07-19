import Image from "next/image";
import Link from "next/link";

const navLinks = [
  { href: "#roles", label: "Pour qui" },
  { href: "#apercu", label: "L'application" },
  { href: "#pourquoi", label: "Pourquoi nous" },
  { href: "#contact", label: "Contact" },
];

export function Header() {
  return (
    <header className="sticky top-0 z-50 border-b border-border bg-background/80 backdrop-blur-xl">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-6 px-6 py-4">
        <Link href="#top" className="flex items-center gap-3">
          <Image
            src="/logo.png"
            alt="Essencia & Co"
            width={46}
            height={46}
            className="rounded-[15px] shadow-[0_8px_22px_rgba(70,40,120,0.14)]"
            priority
          />
          <span className="whitespace-nowrap font-heading text-xl font-bold tracking-tight text-title">
            Essencia &amp; Co
          </span>
        </Link>
        <nav className="hidden items-center gap-7 text-base font-medium text-text md:flex">
          {navLinks.map(({ href, label }) => (
            <a
              key={href}
              href={href}
              className="whitespace-nowrap transition-colors hover:text-primary"
            >
              {label}
            </a>
          ))}
        </nav>
      </div>
    </header>
  );
}
