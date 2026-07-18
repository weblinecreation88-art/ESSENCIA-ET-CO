import Image from "next/image";
import Link from "next/link";

export function Header() {
  return (
    <header className="sticky top-0 z-50 border-b border-border bg-surface/80 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <Link href="#" className="flex items-center gap-2">
          <Image
            src="/logo.png"
            alt="Essencia & Co"
            width={40}
            height={40}
            className="rounded-card"
            priority
          />
          <span className="font-heading text-lg font-semibold text-title">
            Essencia &amp; Co
          </span>
        </Link>
        <nav className="hidden items-center gap-8 text-sm font-medium text-text md:flex">
          <a href="#roles" className="hover:text-primary">
            Pour qui
          </a>
          <a href="#apercu" className="hover:text-primary">
            L&apos;application
          </a>
          <a href="#pourquoi" className="hover:text-primary">
            Pourquoi nous
          </a>
          <a href="#contact" className="hover:text-primary">
            Contact
          </a>
        </nav>
        <a
          href="#contact"
          className="rounded-button bg-primary px-5 py-2.5 text-sm font-semibold text-white shadow-soft transition hover:bg-primary-dark"
        >
          Demander une démo
        </a>
      </div>
    </header>
  );
}
