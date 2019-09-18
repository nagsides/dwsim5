﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using DWSIM.Interfaces;
using DWSIM.Interfaces.Enums.GraphicObjects;
using DWSIM.UnitOperations.UnitOperations;
using DWSIM.UnitOperations.Reactors;
using DWSIM.UnitOperations.SpecialOps;
using DWSIM.UnitOperations.Streams;
using DWSIM.Thermodynamics.Streams;

using Eto.Forms;

using cv = DWSIM.SharedClasses.SystemsOfUnits.Converter;
using Eto.Drawing;

using System.Diagnostics;
using System.IO;

using DWSIM.ExtensionMethods;
using DWSIM.UI.Shared;
using s = DWSIM.UI.Shared.Common;
using System.Collections.ObjectModel;

using global::DWSIM.SharedClasses.Spreadsheet;
using Ciloci.Flee;
using System.Globalization;
using System.Xml.Linq;

namespace DWSIM.UI.Desktop.Editors
{

    public class ScriptItem : TableLayout
    {

        public CheckBox chkLink;
        public DropDown cbLinkedObject, cbLinkedEvent, cbPythonInt;
        public dynamic txtScript;

        private FlowsheetBase.FlowsheetBase flowsheet;

        public ScriptItem(FlowsheetBase.FlowsheetBase fs)
        {
            flowsheet = fs;
            Init();
        }

        void Init()
        {

            chkLink = new CheckBox { Text = "Link Script", Height = 22};
            chkLink.Font = new Font(SystemFont.Default, DWSIM.UI.Shared.Common.GetEditorFontSize());

            var lbl1 = new Label { Text = "Object", VerticalAlignment = VerticalAlignment.Center};
            var lbl2 = new Label { Text = "Event", VerticalAlignment = VerticalAlignment.Center };
            var lbl3 = new Label { Text = "Python Interpreter", VerticalAlignment = VerticalAlignment.Center };

            lbl1.Font = new Font(SystemFont.Default, DWSIM.UI.Shared.Common.GetEditorFontSize());
            lbl2.Font = new Font(SystemFont.Default, DWSIM.UI.Shared.Common.GetEditorFontSize());
            lbl3.Font = new Font(SystemFont.Default, DWSIM.UI.Shared.Common.GetEditorFontSize());

            cbLinkedObject = new DropDown();
            cbLinkedEvent = new DropDown();
            cbPythonInt = new DropDown();

            cbLinkedObject.Font = new Font(SystemFont.Default, DWSIM.UI.Shared.Common.GetEditorFontSize());
            cbLinkedEvent.Font = new Font(SystemFont.Default, DWSIM.UI.Shared.Common.GetEditorFontSize());
            cbPythonInt.Font = new Font(SystemFont.Default, DWSIM.UI.Shared.Common.GetEditorFontSize());

            cbLinkedEvent.Items.AddRange(new String[] { "Simulation Opened", "Simulation Saved", "Simulation Closed", "1 min. Timer", "5 min. Timer", "15 min. Timer", "30 min. Timer", "60 min. Timer" }.Select((x) => new ListItem { Key = x, Text = x }));
            cbPythonInt.Items.AddRange(new String[] { "IronPython", "Python.NET" }.Select((x) => new ListItem { Key = x, Text = x }));

            var tr1 = new TableRow(chkLink, lbl1, cbLinkedObject, lbl2, cbLinkedEvent, null, lbl3, cbPythonInt);
            var tb1 = new TableLayout { Spacing = new Size(5, 5), Padding = new Padding(0, 0, 0, 10) };
            tb1.Rows.Add(tr1);
            tb1.Height = 34;
            
            cbLinkedObject.SelectedIndexChanged += (sender, e) =>
            {
                if (cbLinkedObject.SelectedIndex < 0) return;
                switch (cbLinkedObject.SelectedIndex)
                {
                    case 0:
                        cbLinkedEvent.Items.Clear();
                        cbLinkedEvent.Items.AddRange(new string[] {
			                "Simulation Opened",
			                "Simulation Saved",
			                "Simulation Closed",
			                "1 min. Timer",
			                "5 min. Timer",
			                "15 min. Timer",
			                "30 min. Timer",
			                "60 min. Timer"
		                }.Select((x) => new ListItem { Key = x, Text = x }));
                        break;
                    case 1:
                        cbLinkedEvent.Items.Clear();
                        cbLinkedEvent.Items.AddRange(new string[] {
			                "Solver Started",
			                "Solver Finished",
			                "Recycle Loop"
		                }.Select((x) => new ListItem { Key = x, Text = x }));
                        break;
                    default:
                        cbLinkedEvent.Items.Clear();
                        cbLinkedEvent.Items.AddRange(new string[] {
			                "Object Calculation Started",
			                "Object Calculation Finished",
			                "Object Calculation Error"
		                }.Select((x) => new ListItem { Key = x, Text = x }));
                        break;
                }
                cbLinkedEvent.SelectedIndex = 0;
            };

            Rows.Add(new TableRow(tb1));

            if (!Application.Instance.Platform.IsWpf)
            {
                txtScript = new Eto.Forms.Controls.Scintilla.Shared.ScintillaControl();
                ((Eto.Forms.Controls.Scintilla.Shared.ScintillaControl)txtScript).SetKeywords(1, flowsheet.ScriptKeywordsF);
                var tr3 = new TableRow((Eto.Forms.Controls.Scintilla.Shared.ScintillaControl)txtScript);
                var tb3 = new TableLayout { Spacing = new Size(5, 5) };
                tb3.Rows.Add(tr3);
                Rows.Add(new TableRow(tb3));
            }
            else
            {
                txtScript = new DWSIM.UI.Controls.CodeEditorControl();
                var tr3 = new TableRow((DWSIM.UI.Controls.CodeEditorControl)txtScript);
                var tb3 = new TableLayout { Spacing = new Size(5, 5) };
                tb3.Rows.Add(tr3);
                Rows.Add(new TableRow(tb3));
            }



        }


    }
}