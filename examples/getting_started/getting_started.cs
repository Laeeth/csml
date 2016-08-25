/* This is the main entry point of the sample application. */

namespace Getting.Started {

  // All the classes generated by the csml compiler are declared partial.
  // This means we can extend them with more components (as long as we link
  // the generated code together with this one, in the same assembly).

  public static partial class Foo {
    public static void BipBip(int i, int j) {
      System.Console.WriteLine("C#: BipBip i = " + i + ", j = " + j);
    }

    public static void Main() {
      System.Console.WriteLine("C#: Starting the application.");

      // Initialize the OCaml engine.
      System.Console.WriteLine("C#: Start the OCaml engine.");
      LexiFi.Interop.Csml.Init();
      // Export local C# code to OCaml.
      System.Console.WriteLine("C#: Export components to OCaml.");
      LexiFi.Interop.CsmlGettingStarted.Init();

      // The same implementation supports the two linking mode.
      // If the OCaml code of the application is linked statically together with
      // the OCaml runtime, then the OCaml stub CsmlGettingStarted has already
      // been evaluated and we can immediatly play with the OCaml code.
      // Otherwise, we need to load the OCaml addin that contains all the OCaml code
      // of our application now.
      if (!LexiFi.Interop.Csml.MLStubAvailable("CsmlGettingStarted")) {
        // The method below changes the .cma to .cmxs if the OCaml runtime
        // linked with this application is in native code.
        System.Console.WriteLine("C#: Loading addin with OCaml code.");
        LexiFi.Interop.Csml.LoadFile("getting_started.cma");
      }

      System.Console.WriteLine("C#: Now calling OCaml code.");
      string s = MyStaticClass.DoSomething("foo");
      System.Console.WriteLine("C#: Returning from OCaml code with s = " + s);
    }
  }
}
