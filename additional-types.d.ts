// jest-dom v6 dropped the /extend-expect entry point; its matchers are
// registered from jest.setup.js, which tsc never sees. The reference brings
// the `jest.Matchers` augmentation (toBeInTheDocument and friends) into the
// program so the tests type-check the same matchers they run against.
/// <reference types="@testing-library/jest-dom" />

// Additional type declarations for Next.js modules
declare module 'next/link';
declare module 'next/image';
declare module 'next/router';
declare module 'next/head';
declare module 'next/script';
declare module 'next/dynamic';
declare module 'next/navigation';
declare module 'next/server';
